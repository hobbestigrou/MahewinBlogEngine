package MahewinBlogEngine::Renderer::POD;

use Moose;

use Pod::POM;
use MahewinBlogEngine::Renderer::POD::View;
use Data::Dumper;

has '_pom' => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_pom',
    init_arg => undef
);

sub _build_pom {
    Pod::POM->new( warning => 1 );
}

sub renderer {
    my ( $self, $text ) = @_;

    print 'Salut';
    print $text;

#    $text = '=head1 Essai';
    my $pom = $self->_pom->parse_text($text);

    return MahewinBlogEngine::Renderer::POD::View->print($pom);
}

1;
