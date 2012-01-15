package Text::Simple::Blog::Renderer::HTML;

use strict;
use warnings;

use Moose;

sub renderer {
    my ( $self, $text ) = @_;

    return $text;
}

1;
