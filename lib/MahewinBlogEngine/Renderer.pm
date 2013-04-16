package MahewinBlogEngine::Renderer;

use Moose;
use MooseX::Params::Validate;

use Module::Load;

use MahewinBlogEngine::Exceptions;

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
            load MahewinBlogEngine::Renderer::Markdown;

            my $renderer = MahewinBlogEngine::Renderer::Markdown->new;
            $renderer->renderer(shift);
        },
        html => sub {
            load MahewinBlogEngine::Renderer::HTML;

            my $renderer = MahewinBlogEngine::Renderer::HTML->new();
            $renderer->renderer(shift);
        },
        pod => sub {
            load MahewinBlogEngine::Renderer::POD;

            my $renderer = MahewinBlogEngine::Renderer::POD->new();
            $renderer->renderer(shift);
        },
        textile => sub {
            load MahewinBlogEngine::Renderer::Textile;

            my $renderer = MahewinBlogEngine::Renderer::Textile->new();
            $renderer->renderer(shift);
        },
    };

    return $rend;
};

sub renderer {
    my ( $self, $text, $format ) = validated_list(
        \@_,
        body   => { isa => 'Str' },
        format => { isa => 'Str' }
    );


    if ( my $rend = $self->_renderer_avalaible->{$format} ) {
        $text =~ s/^\s*(\S*(?:\s+\S+)*)\s*$/$1/;
        return $rend->($text);
    }
    else {
        throw_format_not_supported error => "No renderer for this format $format ";
    }

    return;
}

1;
