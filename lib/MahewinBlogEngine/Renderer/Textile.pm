package MahewinBlogEngine::Renderer::Textile;

use Moo;

use Text::Textile;

has '_textile' => (
    is       => 'lazy',
    init_arg => undef
);

sub _build__textile {
    Text::Textile->new;
}

sub renderer {
    my ( $self, $text ) = @_;

    return $self->_textile->process($text);
}

1;
