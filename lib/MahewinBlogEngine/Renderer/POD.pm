package MahewinBlogEngine::Renderer::POD;

use Moo;

use Pod::POM;
use MahewinBlogEngine::Renderer::POD::View;

has '_pom' => (
    is       => 'lazy',
    init_arg => undef
);

sub _build__pom {
    Pod::POM->new( warning => 1 );
}

sub renderer {
    my ( $self, $text ) = @_;

    my $pom = $self->_pom->parse_text($text);
    return MahewinBlogEngine::Renderer::POD::View->print($pom);
}

1;
