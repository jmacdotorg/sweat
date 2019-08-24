package Sweat::Article;

use warnings;
use strict;
use Moo;
use namespace::clean;

use Types::Standard qw( Str Maybe );

use Scalar::Util qw( blessed );
use HTML::Strip;

has 'text' => (
    is => 'ro',
    required => 1,
    isa => Str,
);

has 'url' => (
    is => 'ro',
    required => 1,
);

has 'source' => (
    is => 'ro',
    required => 1,
);

sub new_from_newsapi_article {
    my ( $class, $newsapi_article ) = @_;

    die "Expected a NewsAPI article, got $newsapi_article"
        unless blessed($newsapi_article)
               && $newsapi_article->isa( 'Web::NewsAPI::Article' );

    my $sweat_article = $class->new(
        text => ($newsapi_article->title // q{})
                . q{. }
                . ($newsapi_article->description // q{}),
        url => $newsapi_article->url,
        source => $newsapi_article,
    );

    return $sweat_article;
}

sub new_from_wikipedia_article {
    my ($class, $wikipedia_article ) = @_;

    die "Expected a Wikipedia article, got $wikipedia_article"
        unless blessed($wikipedia_article)
               && $wikipedia_article->isa( 'WWW::Wikipedia::Entry' );

    my $text = HTML::Strip->new->parse($wikipedia_article->text);
    $text =~ s/\{\{[^}]*?\}\}//sg;
    $text =~ s/.*?\}\}//sg;
    $text =~ s{<ref>.*?</ref>}{}sg;
    $text =~ s{<ref[^>]*?/\s*>}{}g;
    $text =~ s{https?://\S+}{}g;

    $text =~ s{^\s*}{};
    $text =~ s{\n\n.*$}{}s;

    $text =~ s{\[\[[^\]]*?\|(.*?)\]\]}{$1}gs;

    my $language = $wikipedia_article->language;
    my $title = $wikipedia_article->title;
    $title =~ s/ /_/g;

    my $url = "https://$language.wikipedia.org/wiki/$title";

    my $sweat_article = $class->new(
        text => ($text // 'No text found for this article, oops.'),
        url => $url,
        source => $wikipedia_article,
    );

    return $sweat_article;
}

1;
