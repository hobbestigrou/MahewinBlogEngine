package MahewinBlogEngine::Articles;

use strict;
use warnings;

use feature qw( state );

use Moo;
extends 'MahewinBlogEngine::Common';

use POSIX;

use MahewinBlogEngine::Exceptions;
use Time::Local qw(timelocal);

use Type::Params qw( compile );
use Type::Utils;
use Types::Standard qw( slurpy Dict Str );

=attr date_order

rw, Str. Specifies the sort order of items asc or desc.

=cut

has date_order => (
    is      => 'rw',
    isa     => Str,
    default => sub { return 'desc' }
);

my $invocant = class_type { class => __PACKAGE__ };

sub BUILD {
    my ($self) = @_;

    $self->_get_or_create_cache('articles');
    return;
}

sub _inject_article {
    my ($self) = @_;

    my @files = sort { $b cmp $a } $self->directory->children;
    my @articles;

    foreach my $file (@files) {
        filename_not_parseable error => 'Filename not parseable: '
        . "$file->basename "
        unless $file->basename =~ /^
        (\d\d\d\d)          # year
        -(\d\d)             # month
        -(\d\d)             # day
        (?:-(\d\d)-(\d\d))? # optional: hour and minute
        (?:-(\d\d))?        # optional: second
        _(.*)               # url part
        \.([a-z]+)          # extension
        $/ix;

        if ( !exists $self->_last_file->{$file} ) {
            my $stat = $file->stat;
            $self->_last_file->{$file} = $stat->[9];
        }

        #Build date, url part and extension
        my $time      = timelocal( $6 // 0, $5 // 0, $4 // 0, $3, $2 - 1, $1 );
        my $url       = lc($7);
        my $extension = lc($8);

        my @lines =
        $file->lines_utf8({chomp  => 0});
        $self->_validate_meta(@lines);

        my $title = shift(@lines);
        my $tags  = shift(@lines);

        $title =~ s/Title:\s//;
        $tags  =~ s/Tags:\s//;

        my $body;
        foreach my $line (@lines) {
            $body .= $line;
        }

        my $content = $self->_renderer->renderer(
            body   => $body,
            format => $extension
        );
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

=method articles_list

  $articles->article_list

Return list of all articles

  input: None
  output: ArrayRef[HashRef]: List of all articles

=cut

sub article_list {
    my ($self) = @_;

    return $self->_sort( $self->_get_or_create_cache('articles') );
}

=method article_details

  $articles->article_details( link => 'foo' );

Return information of article.

  input: link (Int) : required, link of article
  output: Hashref: Details of article

=cut

sub article_details {
    state $check = compile(
        $invocant,
        slurpy Dict[
            link => Str,
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $url = $arg->{link};

    return $self->SUPER::details(
        link => $url,
        type => 'articles'
    );
}

=method article_by_tag

    $articles->article_by_tag( tag => 'world' );

Return a list of articles filter by tag specified.

    input: tag (Str) : tag of filter
    output: ArrayRef[HashRef]: A list of article mathches by tag

=cut

sub article_by_tag {
    state $check = compile(
        $invocant,
        slurpy Dict[
            tag => Str,
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $tag = $arg->{tag};

    return $self->_sort(
        $self->SUPER::by_tag(
            tag  => $tag,
            type => 'articles',
        )
    );
}

sub search {
    state $check = compile(
        $invocant,
        slurpy Dict[
            pattern => Str,
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $str = $arg->{pattern};

    return $self->_sort(
        $self->SUPER::search(
            pattern => $str,
            type    => 'articles',
        )
    );
}

sub _sort {
    my ( $self, $articles ) = @_;


    my @sort = $self->date_order eq 'desc'
        ? sort { $b->{epoch} <=> $a->{epoch} } @{$articles}
        : sort { $a->{epoch} <=> $b->{epoch} } @{$articles};

    return \@sort;
}

1;
