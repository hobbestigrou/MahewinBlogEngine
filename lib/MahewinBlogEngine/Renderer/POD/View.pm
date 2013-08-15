package MahewinBlogEngine::Renderer::POD::View;
use base qw( Pod::POM::View::HTML );

sub view_pod {
    my ($self, $item) = @_;

    return $item->content->present($self);
}

1;
