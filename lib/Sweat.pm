package Sweat;

our $VERSION = 1;

use v5.10;

use warnings;
use strict;
use Types::Standard qw(Int ArrayRef Maybe Str Bool HashRef);

use List::Util qw(shuffle);
use YAML;
use File::Temp qw(tmpnam);
use Web::NewsAPI;
use LWP;
use Try::Tiny;
use utf8::all;
use Term::ReadKey;
use POSIX qw(uname);

use Sweat::Group;

use Moo;
use namespace::clean;

BEGIN {
    binmode STDOUT, ":utf8";
    ReadMode 3;
    $SIG{TERM} => \&clean_up;
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
    default => sub { (uname())[0] eq 'Darwin'? 'say' : 'espeak' },
);

has 'url_program' => (
    is => 'rw',
    isa => Str,
    default => sub { (uname())[0] eq 'Darwin'? 'open' : 'xdg-open' },
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

has 'speaker_pid' => (
    is => 'rw',
    isa => Int,
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
        next if defined $args->{$method};
        my $value = $config->{$method} // 0;
        $self->$method($value);
    }

    for my $method (
        qw(newsapi_key newsapi_country fortune_program speech_program)
    ) {
        next if defined $args->{$method};
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
    $self->clean_up;
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

    my ($extra_text, $url, $article) = $self->entertainment_for_drill( $drill );
    $extra_text //= q{};

    $self->speak( "Start now. $extra_text");
    my $url_tempfile;
    if ( defined $url ) {
        if ( $url =~ m{\Wyoutube.com/} ) {
            $url_tempfile = $self->mangle_youtube_url( $article );
            $url = "file://$url_tempfile";
        }
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
    return unless $seconds;

    my $seconds_label_cutoff = 10;
    my @spoken_seconds = (20, 15, 10, 5, 4, 3, 2, 1);
    my $label = 'seconds left';

    for my $current_second (reverse(0..$seconds)) {
        my $keystroke = ReadKey (1);
        if ( $keystroke ) {
            $self->pause;
        }
        if (
            ( grep {$_ == $current_second} @spoken_seconds )
            || ( $current_second && not ( $current_second % 10 ) )
        ) {
            if ( $current_second >= $seconds_label_cutoff ) {
                $self->speak( "$current_second $label." );
                $label = 'seconds';
            }
            else {
                $self->shut_up; # Final countdown, so interrupt any chattiness
                $self->speak( $current_second );
            }
        }
    }
}

sub shut_up {
    my $self = shift;

    if ( -e $temp_file ) {
        my $group = getpgrp;
        unlink $temp_file;
        $SIG{TERM} = 'IGNORE';
        kill ('TERM', -$group);
        $SIG{TERM} = 'DEFAULT';
    }
}

sub pause {
    my $self = shift;

    $self->shut_up;
    say "***PAUSED*** Press any key to resume.";
    $self->leisurely_speak( 'Paused.' );
    ReadKey (0);
    say "Resuming...";
    $self->leisurely_speak( 'Resuming.' );
}

sub entertainment_for_drill {
    my ( $self, $drill ) = @_;

    unless ($self->entertainment) {
        return (undef, undef);
    }

    my $text;
    my $url;
    my $article;

    if ( $drill->requires_side_switching ) {
        $text = $self->weather;
    }
    else {
        $article = $self->next_article;
        $text = ($article->title // q{})
                . q{. }
                . ($article->description // q{});
        $url = $article->url;
    }

    return ( $text, $url, $article );
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

    return if -e $temp_file;

    my $pid = fork;
    if ( $pid ) {
        $self->speaker_pid( $pid );
    }
    else {
        open my $fh, '>', $temp_file;
        print $fh $pid;
        system ( $self->speech_program, $message );
        unlink $temp_file;
        exit;
    }
}

sub leisurely_speak {
    my ( $self, $message ) = @_;

    system ( $self->speech_program, $message );
}

# mangle_youtube_url: create a local file that just embeds the youtube
#                     video, preventing autoplay.
sub mangle_youtube_url {
    my ( $self, $article ) = @_;
    my $tempfile = File::Temp->new( SUFFIX => '.html' );
    binmode $tempfile, ":utf8";
    my $title = $article->title;
    my $description = $article->description;
    my $url = $article->url;

    my ($video_id) = $url =~ m{v=(\w+)};

    print $tempfile qq{<html><head><title>$title</title></head>}
              . qq{<body><h1>$title</h1>}
              . qq{<p>$description</p>}
              . qq{<div><iframe src="https://www.youtube.com/embed/$video_id" }
              . q{frameborder="0" allow="accelerometer; autoplay; }
              . q{encrypted-media; gyroscope; picture-in-picture" }
              . q{allowfullscreen></iframe></div>}
              . q{<p><em>This article was mangled by Sweat so that its video }
              . q{didn&#8217;t autoplay. You&#8217;re welcome.</em></p>}
              . qq{</body></html>\n};

    return $tempfile;
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

sub clean_up {
    ReadMode 0;
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

=head1 NAME

Sweat - Library for the `sweat` command-line program

=head1 DESCRIPTION

This library is intended for internal use by the L<sweat> command-line program,
and as such offers no publicly documented methods.

=head1 SEE ALSO

L<sweat>

=head1 AUTHOR

Jason McIntosh <jmac@jmac.org>
