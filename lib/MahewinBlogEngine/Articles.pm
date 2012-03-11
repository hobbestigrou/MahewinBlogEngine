package MahewinBlogEngine::Articles;

use strict;
use warnings;

use Moose;

use POSIX;
use Carp;
use File::Spec;

use MahewinBlogEngine::Utils qw(converted_text);
use Time::Local qw(timelocal);

with 'MahewinBlogEngine::Role::File';

has '_articles' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    lazy     => 1,
    builder  => '_build_articles',
    clearer  => 'clear_articles',
    init_arg => undef
);

=attr date_format

ro, Str. Date format used to display, POSIX strftime.
Default value is %x %T.

=cut

has 'date_format' => (
    is      => 'ro',
    isa     => 'Str',
    default => "%x %T"
);

sub _build_articles {
    my ( $self ) = @_;

    my @files     = $self->directory->children;
    my @files_tri = sort { $b cmp $a } @files;
    my @articles;

    foreach my $file (@files_tri) {
        my $relative_path = File::Spec->abs2rel($file, $file->parent);
        croak 'Filename not parseable: ' . $relative_path unless $relative_path =~ /^
            (\d\d\d\d)          # year
            -(\d\d)             # month
            -(\d\d)             # day
            (?:-(\d\d)-(\d\d))? # optional: hour and minute
            (?:-(\d\d))?        # optional: second
            _(.*)               # url part
            \.([a-z]+)          # extension
        $/ix;

        #Build date, url part and extension
        my $time      = timelocal($6 // 0, $5 // 0, $4 // 0, $3, $2 - 1, $1);
        my $url       = lc($7);
        my $extension = lc($8);

        my $encoding = $self->encoding;
        my @lines = $file->slurp(chomp => 0, iomode => "<:encoding($encoding)");
        _validate_meta(@lines);

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

sub _validate_meta {
    my ( @file_content ) = @_;

    if ( $file_content[0] !~ m/^Title:\s+\w+/
      || $file_content[1] !~ m/^Tags:(?:\s\w+)/) {
        croak 'Meta not valid';
    }

    return;
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
