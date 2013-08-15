package MahewinBlogEngine::Renderer;

use feature "state";

use Moo;

use Module::Load;

use MahewinBlogEngine::Exceptions;

use Type::Params qw( compile );
use Type::Utils;
use Types::Standard qw( slurpy Dict Object Str HashRef );

use Data::Dumper;

my $invocant = class_type { class => __PACKAGE__ };

has _renderer_avalaible => (
    is       => 'lazy',
    isa      => HashRef,
    init_arg => undef
);

sub _build__renderer_avalaible {
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
    state $check = compile(
        $invocant,
        slurpy Dict[
            body   => Str,
            format => Str,
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $text   = $arg->{body};
    my $format = $arg->{format};

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
