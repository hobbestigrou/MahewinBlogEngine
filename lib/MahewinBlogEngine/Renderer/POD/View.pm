package MahewinBlogEngine::Renderer::POD::View;
use base qw( Pod::POM::View::HTML );

use Data::Dumper;

sub view_pod {
    my ($self, $item) = @_;

    return $item->content->present($self);
}

1;
