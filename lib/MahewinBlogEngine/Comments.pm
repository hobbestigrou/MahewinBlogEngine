package MahewinBlogEngine::Comments;

use strict;
use warnings;

use Moose;

use Carp;
use File::Spec;

use Time::Local qw(timelocal);
use MahewinBlogEngine::Renderer;

use POSIX qw(strftime);

with 'MahewinBlogEngine::Role::File';

has '_comments' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    lazy     => 1,
    builder  => '_build_comments',
    clearer  => 'clear_comments',
    init_arg => undef
);

sub _build_comments {
    my ( $self ) = @_;

    my @comments;
    $self->directory->recurse( callback => sub {
       my ( $file ) = @_;

       if ( -f $file ) {
           my $relative_path = File::Spec->abs2rel($file, $file->parent);
           croak 'Filename not parseable: ' . $relative_path unless $relative_path =~ /^
                (\d\d\d\d)          # year
                -(\d\d)             # month
                -(\d\d)             # day
                -(\d\d)             # hour
                -(\d\d)             # minute
                -(\d\d)             # second
                \.([a-z]+)          # extension
            $/ix;

            my $time      = timelocal($6, $5, $4, $3, $2 - 1, $1);
            my $extension = lc($7);

            my @lines    = $file->slurp(chomp => 0);

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

            my $renderer = MahewinBlogEngine::Renderer->new();
            my $content  = $renderer->renderer($body, $extension);


            push(@comments, {
                author      => $author,
                mail        => $mail,
                url         => $url,
                hidden      => $hidden // 0,
                url_article => $file->dir->{dirs}->[-1],
                body        => $content,
            });
       }
    });

    \@comments;
}

sub comment_list {
    my ( $self ) = @_;

    return $self->_comments;
}

sub get_comments_by_article {
    my ( $self, $id_article ) = @_;

    my @comments;

    foreach my $comment ( @{$self->_comments} ) {
        push(@comments, $comment) if $comment->{url_article} eq $id_article;
    }

    return \@comments;
}

sub add_comment {
    my ( $self, $id_article , $params ) = @_;

    my $now = strftime "%Y-%m-%d-%H-%M-%S", localtime;

    my $directory = $self->directory->stringify . '/' . "$id_article";
    my $filename  = "$id_article/$now.md";
    my $file      = $self->directory->file($filename);

    mkdir($directory) unless -e $directory;

    my $name   = $params->{name} // 'Anonymous';
    my $mail   = $params->{mail} // '';
    my $body   = $params->{body} =~ s/\cM//g // '';
    my $url    = $params->{url} // '';
    my $hidden = $params->{hidden} // 1;

    my $encoding = $self->encoding;
    my $fh = $file->open(">:encoding($encoding)");
    print $fh "Name: $name" . "\n";
    print $fh "Mail: $mail" . "\n";
    print $fh "Url: $url" . "\n";
    print $fh "Hidden: $hidden" . "\n";
    print $fh $params->{body} if $params->{body};

    $self->clear_comments;

    return;
}

1;
