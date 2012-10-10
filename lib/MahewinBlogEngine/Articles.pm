package MahewinBlogEngine::Articles;

use strict;
use warnings;

use Moose;

use POSIX;
use Carp;
use File::Spec;

use Time::Local qw(timelocal);

with 'MahewinBlogEngine::Role::File';

=attr date_format

ro, Str. Date format used to display, POSIX strftime.
Default value is %x %T.

=cut

has 'date_format' => (
    is      => 'ro',
    isa     => 'Str',
    default => "%x %T"
);

sub _inject_article {
    my ( $self ) = @_;

    my @files     = $self->directory->children;
    my @files_tri = sort { $b cmp $a } @files;

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

        my $title  = shift(@lines);
        my $tags   = shift(@lines);
        my $update = shift(@lines);

        $title  =~ s/Title:\s//;
        $tags   =~ s/Tags:\s//;
        $update =~ s/Update:\s+//;

        my $body;
        foreach my $line (@lines) {
            $body .= $line;
        }

        my $content  = $self->_renderer->renderer($body, $extension);
        my @tags     = split(',', $tags);

        $self->_cache->_add_article({
            title   => $title,
            tags    => \@tags,
            update  => int($update),
            date    => POSIX::strftime($self->date_format, gmtime($time)),
            epoch   => $time,
            content => $content,
            link    => $url
        });
    }
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

    $self->_inject_article;
    return $self->_sort($self->_cache->_article_list);
}

=method article_details

Return information of article.

  input: Str: key: key of article
  output: Hashref: Details of article

=cut

sub article_details {
    my ( $self, $url ) = @_;

    return $self->_cache->_article_details($url);
}

=method get_articles_by_tag

Return a list of articles filter by tag specified.

    input: Str: tag of filter
    output: ArrayRef[HashRef]: A list of article mathches by tag

=cut

sub get_articles_by_tag {
    my ( $self, $tag ) = @_;

    return $self->_sort($self->_cache->_get_articles_by_tag($tag));
}

sub search {
    my ( $self, $str ) = @_;

    return $self->_sort($self->_cache->_search($str));
}

sub _sort {
    my ( $self, $articles ) = @_;

    my @sort = sort { $b->{epoch} <=> $a->{epoch} } @{$articles};
    return \@sort;
}

1;
