package MahewinBlogEngine::Comments;

use feature qw( state );

use Moo;
extends 'MahewinBlogEngine::Common';

use Carp;

use MahewinBlogEngine::Comment;
use MahewinBlogEngine::Exceptions;
use MahewinBlogEngine::Renderer;

use POSIX qw(strftime);

use DateTime;
use DateTime::TimeZone;

use Type::Params qw( compile );
use Type::Utils;
use Types::Standard qw( slurpy Dict Str HashRef );

my $invocant = class_type { class => __PACKAGE__ };

before _get_or_create_cache => sub {
    my ($self) = @_;

    my $file;
    my $iter = $self->directory->iterator({ recurse => 1 });
    while ( $file = $iter->() ) {
        if ( exists $self->_last_file->{$file} ) {
            while ( my ( $key, $value ) = each %{ $self->_last_file } ) {
                my $stat = $file->stat;
                if ( $key eq $file ) {
                    if ( $stat->[9] != $value ) {
                        $self->_last_file->{$file} = $stat->[9];
                        $self->_cache->remove('comments');
                    }
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

    $self->_get_or_create_cache;
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
    my $file;
    my $iter = $self->directory->iterator({ recurse => 1 });
    while ( $file = $iter->() ) {
        if ( $file->is_file ) {
            filename_not_parseable error => 'Filename not parseable: '
            . "$file->basename "
            unless $file->basename =~ /^
            (\d\d\d\d)          # year
            -(\d\d)             # month
            -(\d\d)             # day
            -(\d\d)             # hour
            -(\d\d)             # minute
            -(\d\d)             # second
            \.([a-z]+)          # extension
            $/ix;

            if ( !exists $self->_last_file->{$file} ) {
                my $stat = $file->stat;
                $self->_last_file->{$file} = $stat->[9];
            }

            #Build date, url part and extension
            my $dt = DateTime->new(
                year      => $1,
                month     => $2,
                day       => $3,
                hour      => $4 // 0,
                minute    => $5 // 0,
                second    => $6 // 0,
                time_zone => DateTime::TimeZone->new(
                    name => 'local' )->name(),
            );

            my $extension = lc($7);
            my @lines     = $file->lines_utf8({chomp  => 0});

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

            my $content = $self->_renderer->renderer(
                body   => $body,
                format => $extension
            );
        my $comment =  MahewinBlogEngine::Comment->new(
            author       => $author,
            mail         => $mail,
            date         => $dt,
            link         => $url,
            hidden       => int($hidden) // 0,
            link_article => $file->parent->basename,
            content      => $content,
        );

        push(@comments, $comment);

        }
    }

    return @comments;
}

sub comment_list {
    my ($self) = @_;

    return $self->_get_or_create_cache;
}

sub get_comments_by_article {
    state $check = compile(
        $invocant,
        slurpy Dict[
            id_article => Str,
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $id_article = $arg->{id_article};


    my @comments;

    foreach my $comment ( @{ $self->_get_or_create_cache } ) {
        push( @comments, $comment ) if $comment->{link_article} eq $id_article;
    }

    return \@comments;
}

sub add_comment {
    state $check = compile(
        $invocant,
        slurpy Dict[
            id_article => Str,
            params     => HashRef
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $id_article    = $arg->{id_article};
    my $params = $arg->{params};

    my $now = strftime "%Y-%m-%d-%H-%M-%S", localtime;

    my $directory = $self->directory->stringify . '/' . "$id_article";
    my $filename  = "$id_article/$now.md";
    my $file      = $self->directory->file($filename);

    mkdir($directory) unless -e $directory;

    my $name   = $params->{name} // 'Anonymous';
    my $mail   = $params->{mail} // '';
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
