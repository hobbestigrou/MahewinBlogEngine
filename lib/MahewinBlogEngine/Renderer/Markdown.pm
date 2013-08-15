package MahewinBlogEngine::Renderer::Markdown;

use Moo;

use Text::MultiMarkdown;

has '_markdown' => (
    is       => 'lazy',
    init_arg => undef
);

sub _build__markdown {
    Text::MultiMarkdown->new;
}

sub renderer {
    my ( $self, $text ) = @_;

    return $self->_markdown->markdown($text);
}

1;
