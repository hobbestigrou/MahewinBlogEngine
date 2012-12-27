package MahewinBlogEngine::Articles;

use strict;
use warnings;

use Moose;
extends 'MahewinBlogEngine::Common';

use POSIX;
use Carp;
use File::Spec;

use MahewinBlogEngine::Exceptions;
use Time::Local qw(timelocal);

before _get_or_create_cache => sub {
    my ($self) = @_;

    foreach my $file ( $self->directory->children ) {
        if ( exists $self->_last_file->{$file} ) {
            while ( my ( $key, $value ) = each %{ $self->_last_file } ) {
                my (
                    $dev,   $ino,     $mode, $nlink, $uid,
                    $gid,   $rdev,    $size, $atime, $mtime,
                    $ctime, $blksize, $blocks
                ) = stat($file);
                if ( $key eq $file ) {
                    if ( $mtime != $value ) {
                        $self->_last_file->{$file} = $mtime;
                        $self->_cache->remove('articles');
                    }
                }
            }
        }
        else {
            $self->_cache->remove('articles');
        }
    }

    return;
};

sub BUILD {
    my ($self) = @_;

    $self->_get_or_create_cache;
    return;
}

sub _get_or_create_cache {
    my ($self) = @_;

    my $cache = $self->_cache->get('articles');

    if ( !defined($cache) ) {
        my @articles = $self->_inject_article;
        $self->_cache->set( 'articles', \@articles );
        $cache = $self->_cache->get('articles');
    }

    return $cache;
}

sub _inject_article {
    my ($self) = @_;

    my @files = $self->directory->children;
    my @files_tri = sort { $b cmp $a } @files;
    my @articles;

    foreach my $file (@files_tri) {
        my $relative_path = File::Spec->abs2rel( $file, $file->parent );
        $relative_path =~ /^\./
            and next;
        filename_not_parseable error => 'Filename not parseable: '
          . "$relative_path "
          unless $relative_path =~ /^
            (\d\d\d\d)          # year
            -(\d\d)             # month
            -(\d\d)             # day
            (?:-(\d\d)-(\d\d))? # optional: hour and minute
            (?:-(\d\d))?        # optional: second
            _(.*)               # url part
            \.([a-z]+)          # extension
        $/ix;

        if ( !exists $self->_last_file->{$file} ) {
            my (
                $dev,   $ino,     $mode, $nlink, $uid,
                $gid,   $rdev,    $size, $atime, $mtime,
                $ctime, $blksize, $blocks
            ) = stat($file);
            $self->_last_file->{$file} = $mtime;
        }

        #Build date, url part and extension
        my $time      = timelocal( $6 // 0, $5 // 0, $4 // 0, $3, $2 - 1, $1 );
        my $url       = lc($7);
        my $extension = lc($8);

        my $encoding = $self->encoding;
        my @lines =
          $file->slurp( chomp => 0, iomode => "<:encoding($encoding)" );
        _validate_meta(@lines);

        my $title = shift(@lines);
        my $tags  = shift(@lines);

        $title =~ s/Title:\s//;
        $tags  =~ s/Tags:\s//;

        my $body;
        foreach my $line (@lines) {
            $body .= $line;
        }

        my $content = $self->_renderer->renderer( $body, $extension );
        my @tags = split( ',', $tags );

        push(
            @articles,
            {
                title   => $title,
                tags    => \@tags,
                date    => POSIX::strftime( $self->date_format, gmtime($time) ),
                epoch   => $time,
                content => $content,
                link    => $url
            }
        );
    }

    return @articles;
}

sub _validate_meta {
    my (@file_content) = @_;

    if (   $file_content[0] !~ m/^Title:\s+\w+/
        || $file_content[1] !~ m/^Tags:(?:\s\w+)/ )
    {
        meta_not_valid error => 'Meta not valid';
    }

    return;
}

=method articles_list

Return list of all articles

  input: None
  output: ArrayRef[HashRef]: List of all articles

=cut

sub article_list {
    my ($self) = @_;

    return $self->_sort( $self->_get_or_create_cache );
}

=method article_details

Return information of article.

  input: Str: key: key of article
  output: Hashref: Details of article

=cut

sub article_details {
    my ( $self, $url ) = @_;

    foreach my $article ( @{ $self->_get_or_create_cache } ) {
        return $article if $article->{link} eq $url;
    }

    return;
}

=method article_by_tag

Return a list of articles filter by tag specified.

    input: Str: tag of filter
    output: ArrayRef[HashRef]: A list of article mathches by tag

=cut

sub article_by_tag {
    my ( $self, $tag ) = @_;

    my @articles;

    foreach my $article ( @{ $self->_get_or_create_cache } ) {
        push( @articles, $article ) if grep( /$tag/, @{ $article->{tags} } );
    }

    return $self->_sort( \@articles );
}

sub search {
    my ( $self, $str ) = @_;

    my @results;
    foreach my $article ( @{ $self->_get_or_create_cache } ) {
        if ( $article->{title} =~ /$str/i || $article->{content} =~ /$str/i ) {
            push( @results, $article );
        }
    }

    return $self->_sort( \@results );
}

sub _sort {
    my ( $self, $articles ) = @_;

    my @sort = sort { $b->{epoch} <=> $a->{epoch} } @{$articles};
    return \@sort;
}

1;
