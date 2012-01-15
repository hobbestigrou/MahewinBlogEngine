package MahewinBlogEngine::Renderer::Markdown;

use Moose;

use Text::Markdown;

has '_markdown' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_markdown'
);

sub _build_markdown {
    Text::Markdown->new;
}

sub renderer {
    my ( $self, $text ) = @_;

    return $self->_markdown->markdown($text);
}

1;
