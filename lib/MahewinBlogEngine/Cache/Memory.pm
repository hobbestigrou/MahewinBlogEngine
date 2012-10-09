package MahewinBlogEngine::Cache::Memory;

use Moose;

use MahewinBlogEngine::Cache::Memory::Article;
use Data::Dumper;

has _articles => (
    traits  => ['Array'],
    is      => 'ro',
    isa     =>'ArrayRef[MahewinBlogEngine::Cache::Memory::Article]',
    default => sub { [] },
    handles => {
        add_art => 'push'
    }
);

has _comments => (
    traits  => ['Array'],
    is      => 'ro',
    isa     =>'ArrayRef[MahewinBlogEngine::Cache::Memory::Comment]',
    default => sub { [] },
    handles => {
        add_com => 'push'
    }
);

sub _add_article {
    my ( $self, $article ) = @_;

    if ( $self->_article_details($article->{link})
        && $article->{update}
        && $self->_article_details($article->{link}->{nb_comments}) != $article->{nb_comments}) {
        $self->_update_article( $article );
        return;
    }

    $self->_article_details($article->{link})
        and return;
    $self->add_art(MahewinBlogEngine::Cache::Memory::Article->new(%{$article}));

    return;
}

sub _update_article {
    my ( $self, $article ) = @_;

    foreach my $old_article (@{$self->_articles}) {
        if ( $old_article->{link} eq $article->{link} ) {
            while ( my ( $key, $value ) = each %{$article} ) {
                $old_article->{$key} = $value;
            }
        }
    }

    return;
}

sub _article_list {
    my ( $self ) = @_;

    return $self->_articles;
}

sub _article_details {
    my ( $self, $url ) = @_;

    foreach my $article ( @{$self->_articles} ) {
        return $article if $article->{link} eq $url;
    }

    return;
}

sub get_articles_by_tag {
    my ( $self, $tag ) = @_;

    my @articles;

    foreach my $article ( @{$self->_articles} ) {
        push(@articles, $article) if grep(/$tag/, @{$article->{tags}});
    }

    return \@articles;
}

sub search {
    my ( $self, $str ) = @_;

    my @results;
    foreach my $article ( @{$self->_articles} ) {
        if ( $article->{title} =~ /$str/i || $article->{content} =~ /$str/i ) {
            push(@results, $article);
        }
    }

    return \@results // [];
}

sub _add_comment {
    my ( $self, $comment ) = @_;

    $self->add_art(MahewinBlogEngine::Cache::Memory::Comment->new(%{$comment}));
    return;
}

sub _comment_list {
    my ( $self ) = @_;

    return $self->_comments;
}

sub _get_comments_by_article {
    my ( $self, $id_article ) = @_;

    my @comments;

    foreach my $comment ( @{$self->_comments} ) {
        push(@comments, $comment) if $comment->{url_article} eq $id_article;
    }

    return \@comments;
}

1;

__END__
