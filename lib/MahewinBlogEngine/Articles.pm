package MahewinBlogEngine::Articles;

use strict;
use warnings;

use Moose;


use POSIX;
use Carp;

use File::Slurp;
use MahewinBlogEngine::Utils qw(converted_text);
use Time::Local qw(timelocal);

has '_articles' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    lazy     => 1,
    builder  => '_build_articles',
    clearer  => 'clear_articles',
    init_arg => undef
);

=attr directory

rw, required, Str. The directory contain articles.

=cut

has 'directory' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

=attr date_format

ro, Str. Date format used to display, POSIX strftime.
Default value is %x %T.

=cut

has 'date_format' => (
    is => 'ro',
    isa => 'Str',
    default => "%x %T"
);

=attr encoding

rw, Str. Indicate the encoding file. Default is utf8.

=cut

has 'encoding' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'utf8'
);


sub _build_articles {
    my ( $self ) = @_;

    my $directory = $self->directory;
    my @files     = read_dir($directory);
    my @files_tri = sort { $b cmp $a } @files;
    my @articles;

    foreach my $file (@files_tri) {
        croak 'Filename not parseable: ' . $file unless $file =~ /^
            (\d\d\d\d)          # year
            -(\d\d)             # month
            -(\d\d)             # day
            (?:-(\d\d)-(\d\d))? # optional: hour and minute
            _(.*)               # url part
            \.([a-z]+)          # extension
        $/ix;

        #Build date, url part and extension
        my $time      = timelocal(0, $5 // 0, $4 // 0, $3, $2 - 1, $1);
        my $url       = lc($6);
        my $extension = lc($7);

        my @lines = read_file("$directory/$file", binmode => ':' . $self->encoding);
        my $title = shift(@lines);
        my $tags  = shift(@lines);

        $title =~ s/Title:\s//;
        $tags  =~ s/Tags:\s//;

        my $body;
        foreach my $line (@lines) {
            $body .= $line;
        }

        my $content = converted_text($body, $extension);
        my @tags    = split(',', $tags);

        push(@articles, {
            title   => $title,
            tags    => \@tags,
            date    => POSIX::strftime($self->date_format, gmtime($time)),
            content => $content,
            link    => $url
        });
    }

    \@articles;
}

=method articles_list

Return list of all articles

  input: None
  output: ArrayRef[HashRef]: List of all articles

=cut

sub article_list {
    my ( $self ) = @_;

    return $self->_articles;
}

=method article_details

Return information of article.

  input: Str: key: key of article
  output: Hashref: Details of article

=cut

sub article_details {
    my ( $self, $url ) = @_;

    foreach my $article ( @{$self->_articles} ) {
        return $article if $article->{link} eq $url;
    }

    return;
}

=method get_articles_by_tag

Return a list of articles filter by tag specified.

    input: Str: tag of filter
    output: ArrayRef[HashRef]: A list of article mathches by tag

=cut

sub get_articles_by_tag {
    my ( $self, $tag ) = @_;

    my @articles;

    foreach my $article ( @{$self->_articles} ) {
        push(@articles, $article) if grep(/$tag/, @{$article->{tags}});
    }

    return \@articles;
}

1;
