package MahewinBlogEngine::Comments;

use strict;
use warnings;

use Moose;
extends 'MahewinBlogEngine::Common';

use Carp;
use File::Spec;

use Time::Local qw(timelocal);

use MahewinBlogEngine::Exceptions;
use MahewinBlogEngine::Renderer;

use POSIX qw(strftime);

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
                    $mtime == $value
                      and $self->_cache->remove('comments');
                }
            }
        }
        else {
            $self->_cache->remove('comments');
        }
    }

    return;
};

sub BUILD {
    my ($self) = @_;

    $self->_inject_comment;
    return;
}

sub _get_or_create_cache {
    my ($self) = @_;

    my $cache = $self->_cache->get('comments');

    if ( !defined($cache) ) {
        my @comments = $self->_inject_comment;
        $self->_cache->set( 'comments', \@comments );
        $cache = $self->_cache->get('comments');
    }

    return $cache;
}

sub _inject_comment {
    my ($self) = @_;

    my @comments;
    $self->directory->recurse(
        callback => sub {
            my ($file) = @_;

            if ( -f $file ) {
                my $relative_path = File::Spec->abs2rel( $file, $file->parent );
                filename_not_parseable error => 'Filename not parseable: '
                  . "$relative_path "
                  unless $relative_path =~ /^
                (\d\d\d\d)          # year
                -(\d\d)             # month
                -(\d\d)             # day
                -(\d\d)             # hour
                -(\d\d)             # minute
                -(\d\d)             # second
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

                my $time      = timelocal( $6, $5, $4, $3, $2 - 1, $1 );
                my $extension = lc($7);
                my @lines     = $file->slurp( chomp => 0 );

                my $author = shift(@lines);
                my $mail   = shift(@lines);
                my $url    = shift(@lines);
                my $hidden = shift(@lines);

                $author =~ s/Name:\s//;
                $mail   =~ s/Mail:\s//;
                $url    =~ s/Url:\s//;
                $hidden =~ s/Hidden:\s//;

                my $body;
                foreach my $line (@lines) {
                    $body .= $line;
                }

                $body //= '';

                my $content = $self->_renderer->renderer( $body, $extension );

                push(
                    @comments,
                    {
                        author      => $author,
                        mail        => $mail,
                        epoch       => $time,
                        key         => $author . '_' . $time,
                        url         => $url,
                        hidden      => int($hidden) // 0,
                        url_article => $file->dir->{dirs}->[-1],
                        body        => $content,
                    }
                );
            }
        }
    );

    return @comments;
}

sub comment_list {
    my ($self) = @_;

    return $self->_get_or_create_cache;
}

sub get_comments_by_article {
    my ( $self, $id_article ) = @_;

    my @comments;

    foreach my $comment ( @{ $self->_get_or_create_cache } ) {
        push( @comments, $comment ) if $comment->{url_article} eq $id_article;
    }

    return \@comments;
}

sub add_comment {
    my ( $self, $id_article, $params ) = @_;

    my $now = strftime "%Y-%m-%d-%H-%M-%S", localtime;

    my $directory = $self->directory->stringify . '/' . "$id_article";
    my $filename  = "$id_article/$now.md";
    my $file      = $self->directory->file($filename);

    mkdir($directory) unless -e $directory;

    my $name = $params->{name} // 'Anonymous';
    my $mail = $params->{mail} // '';
    my $body   = $params->{body} =~ s/\cM//g // '';
    my $url    = $params->{url}              // '';
    my $hidden = int( $params->{hidden} )    // 1;

    my $encoding = $self->encoding;
    my $fh       = $file->open(">:encoding($encoding)");
    print $fh "Name: $name" . "\n";
    print $fh "Mail: $mail" . "\n";
    print $fh "Url: $url" . "\n";
    print $fh "Hidden: $hidden" . "\n";
    print $fh $params->{body} if $params->{body};

    return;
}

1;
