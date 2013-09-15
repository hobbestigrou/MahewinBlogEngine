#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 5;
use Test::Differences::Color;

use Cwd;
use MahewinBlogEngine;

use YAML::Syck;

my $articles = MahewinBlogEngine->articles(
    directory => getcwd() . '/t/articles'
);
my $expcted_file = LoadFile('/vagrant_data/MahewinBlogEngine/t/expcted/articles.yaml');

my $list    = $expcted_file->{list};
my $details = $expcted_file->{detail};
my $tags    = $expcted_file->{tag};
my $search  = $expcted_file->{search};

sub reverse_article {
    my ($articles_list) = @_;

    my $articles_reverse = [];
    foreach my $art (@{$articles_list}) {
        unshift($articles_reverse, $art);
    }

    return $articles_reverse;
}

sub replace_date {
    my ($article) = @_;

    if ( ref($article) eq 'ARRAY' ) {
        foreach my $art (@{$article}) {
            $art->{date} = ref($art->{date});
        }
     }
     else {
         $article->{date} = ref($article->{date});
     }

    return $article;
}

eq_or_diff $list, replace_date($articles->article_list), "Testing articles list";
eq_or_diff $details, replace_date($articles->article_details(
    link => 'hello_world' )), "Testing article details";
eq_or_diff $tags, replace_date($articles->article_by_tag(
    tag => 'test')), "Testing articles tags";
eq_or_diff $search, replace_date($articles->search(
    pattern => 'world' )), "Testing articles search";

$articles->date_order('asc');
eq_or_diff reverse_article($list), replace_date($articles->article_list), "Testing articles list asc";

done_testing;
