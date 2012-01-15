package Text::Simple::Blog;

use strict;
use warnings;

use Moose;

use Text::Simple::Blog::Articles;
use Text::Simple::Blog::Comments;

#ABSTRACT: A simple blog engine

sub articles {
    my ( $self, $args ) = @_;

    my $articles = Text::Simple::Blog::Articles->new($args);
    return $articles;
}

sub comments {
    my ( $self, $args ) = @_;

    my $comments = Text::Simple::Blog::Comments->new($args);
    return $comments;
}

1;
