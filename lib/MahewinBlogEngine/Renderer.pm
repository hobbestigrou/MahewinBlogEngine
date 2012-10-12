package MahewinBlogEngine::Renderer;

use Moose;
use Carp;

use aliased 'MahewinBlogEngine::Renderer::Markdown';
use aliased 'MahewinBlogEngine::Renderer::HTML';
use MahewinBlogEngine::Exceptions;
use Data::Dumper;

has _renderer_avalaible => (
    is       => 'ro',
    isa      => 'HashRef',
    lazy     => 1,
    builder  => '_build_renderer_avalaible',
    init_arg => undef
);

sub _build_renderer_avalaible {
    my $rend = {
        md   => sub {
            my $renderer = Markdown->new;
            $renderer->renderer(shift);
        },
        html => sub {
            my $renderer = HTML->new();
            $renderer->renderer(shift);
        },
    };

    return $rend;
};

sub renderer {
    my ( $self, $text, $format ) = @_;


    if ( my $rend = $self->_renderer_avalaible->{$format} ) {
        return $rend->($text);
    }
    else {
        throw_format_not_supported error => "No renderer for this format $format ";
    }

    return;
}

1;
