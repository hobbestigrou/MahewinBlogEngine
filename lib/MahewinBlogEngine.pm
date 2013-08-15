package MahewinBlogEngine;

use strict;
use warnings;

use Moo;

use MahewinBlogEngine::Articles;
use MahewinBlogEngine::Comments;

#ABSTRACT: A simple blog engine

sub articles {
    my ( $self, %args ) = @_;

    my $articles = MahewinBlogEngine::Articles->new(%args);
    return $articles;
}

sub comments {
    my ( $self, %args ) = @_;

    my $comments = MahewinBlogEngine::Comments->new(%args);
    return $comments;
}

1;
