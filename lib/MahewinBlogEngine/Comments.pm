package MahewinBlogEngine::Comments;

use strict;
use warnings;

use Moose;

use Carp;

use File::Slurp;
use Time::Local qw(timelocal);
use MahewinBlogEngine::Utils qw(converted_text);

has '_comments' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
    builder => '_build_comments'
);

=attr directory

rw, required, Str. The directory contain comments.

=cut

has 'directory' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

sub _build_comments {
    my ( $self ) = @_;

    my $direct    = $self->directory;
    my @directory = read_dir($direct);
    my @comments;

    foreach my $dir (@directory) {
        opendir(COMMENTS, "$direct/$dir");

        while(defined (my $file = readdir(COMMENTS))) {
            next if $file eq '.' || $file eq '..';
            croak 'Filename not parseable: ' . $file unless $file =~ /^
                (\d\d\d\d)          # year
                -(\d\d)             # month
                -(\d\d)             # day
                -(\d\d)             # hour
                -(\d\d)             # minute
                -(\d\d)             # second
                \.([a-z]+)          # extension
            $/ix;

            my @lines  = read_file("$direct/$dir/$file");
            my $author = shift(@lines);
            my $mail   = shift(@lines);
            my $url    = shift(@lines);
            my $hidden = shift(@lines);

            $author =~ s/Name:\s//;
            $mail   =~ s/Mail:\s//;
            $url    =~ s/Url:\s//;
            $hidden =~ s/Hidden:\s//;

            my $time      = timelocal($6, $5, $4, $3, $2 - 1, $1);
            my $extension = lc($7);

            my $body;
            foreach my $line (@lines) {
                $body .= $line;
            }

            $body //= '';

            my $content = converted_text($body, $extension);

            push(@comments, {
                    author      => $author,
                    mail        => $mail,
                    url         => $url,
                    hidden      => $hidden,
                    url_article => $dir,
                    body        => $content,
                });
            }

            closedir(COMMENTS);
        }

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

    my ( $sec, $min, $hour, $day, $m, $y ) = localtime;

    my $mon      = $m + 1;
    my $year     = $y + 1900;
    $mon         = $mon =~ m/^\d$/ ? "0$mon" : $mon;
    $day         =~ s/^\d$/0$day/;
    $sec         = $sec =~ m/^\d$/ ? "0$sec" : $sec;
    $min         = $min =~ m/^\d$/ ? "0$min" : $min;
    $hour        = $hour =~ m/^\d$/ ? "0$hour" : $hour;

    my $directory = $self->directory;
    my $filename  = "$directory/$id_article/$year-$mon-$day-$hour-$min-$sec.md";

    mkdir("$directory/$id_article") unless -e "$directory/$id_article";

    my $name   = $params->{name} // 'Anonymous';
    my $mail   = $params->{mail} // '';
    my $body   = $params->{body} // '';
    my $url    = $params->{url} // '';
    my $hidden = $params->{hidden} // 1;

    my @data = ( "Name: $name", "\n", "Mail: $mail", "\n", "Url: $url", "\n", "Hidden: $hidden", "\n", $params->{body} );
    write_file( $filename, { binmode => ':utf8' }, @data );

    push($self->_comments, {
        author      => $name,
        mail        => $mail,
        url         => $url,
        hidden      => $hidden,
        url_article => $id_article,
        body        => $body,
    });

    return;
}

1;
