#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Differences::Color;

use Cwd;
use MahewinBlogEngine;

use YAML::Syck;

my $pages = MahewinBlogEngine->pages(
    directory => getcwd() . '/t/pages'
);
my $expcted_file = LoadFile(getcwd() . '/t/expcted/pages.yaml');

my $list    = $expcted_file->{list};
my $details = $expcted_file->{detail};
my $tags    = $expcted_file->{tag};

eq_or_diff $list, $pages->list, "Testing pages list";
eq_or_diff $details, $pages->details(
    link => 'another_page' ), "Testing page details";
eq_or_diff $tags, $pages->by_tag(
    tag => 'another'), "Testing pages tags";
eq_or_diff $list, $pages->search(
    pattern => 'Just' ), "Testing pages search";

done_testing;
