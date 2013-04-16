package MahewinBlogEngine::Renderer::Textile;

use Moose;

use Text::Textile;

has '_textile' => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_textile',
    init_arg => undef
);

sub _build_textile {
    Text::Textile->new;
}

sub renderer {
    my ( $self, $text ) = @_;

    return $self->_textile->process($text);
}

1;
