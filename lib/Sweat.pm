package Sweat;

# XXX PUNCHLIST
# * Make a test that uses srand(1)
# * Make the

our $VERSION = 1;

use v5.10;

use strictures 2;
use Types::Standard qw(Int ArrayRef Maybe Str Bool HashRef);

use List::Util qw(shuffle);
use YAML;
use File::Temp qw(tmpnam);
use Web::NewsAPI;
use LWP;
use Try::Tiny;
use utf8::all;

use Sweat::Group;

use Moo;
use namespace::clean;

BEGIN {
    binmode STDOUT, ":utf8";
}

has 'groups' => (
    is => 'lazy',
    isa => ArrayRef,
);

has 'group_config' => (
    is => 'rw',
    isa => ArrayRef,
    default => sub { _default_group_config( @_ ) },
);

has 'drills' => (
    is => 'lazy',
    isa => ArrayRef,
);

has 'drill_count' => (
    is => 'rw',
    isa => Int,
    required => 1,
    default => 12,
);

has 'drill_counter' => (
    is => 'rw',
    isa => Int,
    default => 0,
);

has 'config' => (
    is => 'ro',
    isa => Maybe[Str],
);

has 'shuffle' => (
    is => 'rw',
    default => 0,
    isa => Bool,
);

has 'entertainment' => (
    is => 'rw',
    default => 0,
    isa => Bool,
);

has 'no_chair' => (
    is => 'rw',
    default => 0,
    isa => Bool,
);

has 'no_jumping' => (
    is => 'rw',
    default => 0,
    isa => Bool,
);

has 'drill_length' => (
    is => 'rw',
    isa => Int,
    default => 30,
);

has 'drill_rest_length' => (
    is => 'rw',
    isa => Int,
    default => 10,
);

has 'drill_prep_length' => (
    is => 'rw',
    isa => Int,
    default => 1,
);

has 'side_switch_length' => (
    is => 'rw',
    isa => Int,
    default => 4,
);

has 'speech_program' => (
    is => 'rw',
    isa => Str,
    default => 'say',
);

has 'url_program' => (
    is => 'rw',
    isa => Str,
    default => 'open',
);

has 'fortune_program' => (
    is => 'rw',
    isa => Str,
    default => 'fortune',
);

has 'newsapi_key' => (
    is => 'rw',
    isa => Maybe[Str],
);

has 'newsapi_country' => (
    is => 'rw',
    isa => Str,
    default => 'us',
);

has 'articles' => (
    is => 'lazy',
    isa => ArrayRef,
);

has 'weather' => (
    is => 'lazy',
    isa => Str,
);

sub BUILD {
    my ($self, $args) = @_;

    my $config;

    try {
        $config = Load( $self->config );
    }
    catch {
        die "Can't load the config file! Here's the error from the YAML parser: "
            . $_
            . "\n";
    };

    for my $method( qw(shuffle entertainment no_chair no_jumping)) {
        my $value = $config->{$method} // 0;
        $self->$method($value);
    }

    for my $method (qw(newsapi_key newsapi_country fortune_program speech_program)) {
        $self->$method($config->{$method}) if defined($config->{$method});
    }

    if ( my $group_data = $config->{groups} ) {
        $self->group_config( $group_data );
    }

    if ( $self->entertainment ) {
        say "Loading entertainment...";
        $self->_build_articles;
        $self->_build_weather;
        say "...done.";
    }
}

sub _build_articles {
    my $self = shift;

    my $newsapi;

    try {
        $newsapi = Web::NewsAPI->new(
            api_key => $self->newsapi_key,
        );
        my $result = $newsapi->top_headlines(
            country => $self->newsapi_country,
            pageSize => $self->drill_count,
        );
        return [ $result->articles ];
    }
    catch {
        die "Sweat ran into a problem fetching news articles: $_\n";
    };

}

my $temp_file = tmpnam();

sub sweat {
    my $self = shift;

    for my $drill (@{ $self->drills }) {
        $self->order($drill);
    }

    $self->cool_down;
}

sub order {
    my ( $self, $drill ) = @_;

    $self->drill_counter( $self->drill_counter + 1 );

    $self->speak(
        'Prepare for '
        . $drill->name
        . '. Drill '
        . $self->drill_counter
        . '.'
    );
    $self->countdown($self->drill_rest_length);

    my ($extra_text, $url) = $self->entertainment_for_drill( $drill );
    $extra_text //= q{};

    $self->speak( "Start now. $extra_text");
    if ( defined $url ) {
        system( $self->url_program, $url );
    }

    if ( $drill->requires_side_switching ) {
        $self->countdown( $self->drill_length / 2 );
        $self->speak( 'Switch sides.');
        $self->countdown( $self->side_switch_length );
        $self->speak( 'Resume.' );
        $self->countdown( $self->drill_length / 2 );
    }
    else {
        $self->countdown( $self->drill_length );
    }

    $self->speak( 'Rest.' );
    sleep $self->drill_prep_length;
}

sub countdown {
    my ($self, $seconds) = @_;

    my $seconds_label_cutoff = 10;
    my @spoken_seconds = (20, 15, 10, 5, 4, 3, 2, 1);
    my $label = 'seconds left';

    for my $current_second (reverse(0..$seconds)) {
        sleep 1;
        if (
            ( grep {$_ == $current_second} @spoken_seconds )
            || ( $current_second && not ( $current_second % 10 ) )
        ) {
            if ( $current_second >= $seconds_label_cutoff ) {
                $self->speak( "$current_second $label." );
                $label = 'seconds';
            }
            else {
                $self->speak( $current_second );
            }
        }
    }
}

sub entertainment_for_drill {
    my ( $self, $drill ) = @_;

    unless ($self->entertainment) {
        return (undef, undef);
    }

    my $text;
    my $url;

    if ( $drill->requires_side_switching ) {
        $text = $self->weather;
    }
    else {
        my $article = $self->next_article;
        $text = $article->title
                . q{. }
                . $article->description;
        $url = $article->url;
    }

    return ( $text, $url );
}


sub fortune {
    my $self = shift;

    return q{} unless $self->entertainment;

    my $exec = $self->fortune_program;

    no warnings;
    my $text = `$exec` // '';
    use warnings;

    unless (length $text) {
        warn "Sweat tried to fetch a fortune by running `$exec`, but didn't "
             . "get any output. Sorry!\n";
    }

    return $text;
}

sub next_article {
    my $self = shift;

    return shift @{ $self->articles };
}

sub _build_weather {
    my $self = shift;

    my $weather;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get('http://wttr.in?format=3');
    if ( $response->is_success ) {
        $weather = 'The current weather in ' . $response->content;
    }
    else {
        $weather = 'Could not fetch the current weather. Sorry about that.';
    }
    return $weather;
}

sub cool_down {
    my $self = shift;

    $self->speak(
        'Workout complete. ' . $self->fortune
    );
}

sub speak {
    my ( $self, $message ) = @_;

    say $message;

    my $pid = fork;
    unless ( $pid ) {
        unless ( -e $temp_file ) {
            open my $fh, '>', $temp_file;
            print $fh $pid;
            system ( $self->speech_program, $message );
            unlink $temp_file;
        }
        exit;
    }
}

sub _build_drills {
    my $self = shift;

    my @final_drills;

    while (@final_drills < $self->drill_count) {
        for my $group ( @{ $self->groups } ) {
            my @drills = $group->unused_drills;

            unless ( @drills ) {
                $group->reset_drills;
                @drills = $group->unused_drills;
            }

            if ( $self->shuffle ) {
                @drills = shuffle(@drills);
            }

            $drills[0]->is_used( 1 );
            push @final_drills, $drills[0];

            last if @final_drills == $self->drill_count;
        }
    }

    return \@final_drills;
}

sub _build_groups {
    my $self = shift;

    return [ Sweat::Group->new_from_config_data( $self, $self->group_config ) ];

}

sub _default_group_config {
    my $self = shift;
    return Load(<<END);
- name: aerobic
  drills:
    - name: jumping jacks
      requires_jumping: 1
    - name: high knees
      requires_jumping: 1
    - name: step-ups
      requires_a_chair: 1
- name: lower-body
  drills:
    - name: wall sit
    - name: squats
    - name: knee lunges
- name: upper-body
  drills:
    - name: push-ups
    - name: tricep dips
      requires_a_chair: 1
    - name: rotational push-ups
- name: core
  drills:
    - name: abdominal crunches
    - name: plank
    - name: side plank
      requires_side_switching: 1
END
}

1;

=head1 Sweat - Library for the `sweat` command-line program

=head1 DESCRIPTION

This library is intended for internal use by the L<sweat> command-line program,
and as such offers no publicly documented methods.

=head1 SEE ALSO

L<sweat>

=head1 AUTHOR

Jason McIntosh <jmac@jmac.org>
