package MahewinBlogEngine::Pages;

use strict;
use warnings;

use feature qw( state );

use Moo;
extends 'MahewinBlogEngine::Common';

use MahewinBlogEngine::Exceptions;

use Type::Params qw( compile );
use Type::Utils;
use Types::Standard qw( slurpy Dict Str );

my $invocant = class_type { class => __PACKAGE__ };

sub BUILD {
    my ($self) = @_;

    $self->_get_or_create_cache('pages');
    return;
}

sub _inject_article {
    my ($self) = @_;

    my @files = sort { $b cmp $a } $self->directory->children;
    my @pages;

    foreach my $file (@files) {
        filename_not_parseable error => 'Filename not parseable: '
        . $file->basename . "\n"
        unless $file->basename =~ /^
        (.*)               # url part
        \.([a-z]+)          # extension
        $/ix;

        if ( !exists $self->_last_file->{$file} ) {
            my $stat = $file->stat;
            $self->_last_file->{$file} = $stat->[9];
        }

        #Build url part and extension
        my $url       = lc($1);
        my $extension = lc($2);

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
            @pages,
            {
                title   => $title,
                tags    => \@tags,
                content => $content,
                link    => $url
            }
        );
    }

    return @pages;
}

=method list

  $pages->list

Return list of all pages.

  input: None
  output: ArrayRef[HashRef]: List of all pages

=cut

sub list {
    my ($self) = @_;

    return $self->_get_or_create_cache('pages');
}

=method details

  $pages->details( link => 'foo' );

Return information of page.

  input: link (Str) : required, link of article
  output: Hashref: Details of page

=cut

sub details {
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
        type => 'pages'
    );
}

=method by_tag

    $pages->by_tag( tag => 'world' );

Return a list of pages filter by tag specified.

    input: tag (Str) : tag of filter
    output: ArrayRef[HashRef]: A list of pages mathches by tag

=cut

sub by_tag {
    state $check = compile(
        $invocant,
        slurpy Dict[
            tag => Str,
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $tag = $arg->{tag};

    return $self->SUPER::by_tag(
        tag  => $tag,
        type => 'pages',
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

    return $self->SUPER::search(
        pattern => $str,
        type    => 'pages',
    );
}

1;
