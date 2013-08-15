#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Differences::Color;

use Cwd;
use MahewinBlogEngine;

my $pages = MahewinBlogEngine->pages(
    directory => getcwd() . '/t/pages'
);
my $list = [{
            'tags' => [
                        'another',
                        ' page
'
                      ],
            'title' => 'Another page
',
            'content' => '<p>Just another page to test.</p>
',
            'link' => 'another_page'
          },
          {
            'tags' => [
                        'about',
                        ' me
'
                      ],
            'title' => 'About
',
            'link' => 'about',
            'content' => '<p>Just about page to test.</p>
'
}];
my $details = {
    'tags' => [
        'another',
        ' page
'
        ],
    'title' => 'Another page
',
    'content' => '<p>Just another page to test.</p>
',
    'link' => 'another_page'
};
my $tag = [{
    'tags' => [
        'another',
        ' page
'
        ],
    'title' => 'Another page
',
    'content' => '<p>Just another page to test.</p>
',
    'link' => 'another_page'
}];

eq_or_diff $list, $pages->list, "Testing pages list";
eq_or_diff $details, $pages->details(
    link => 'another_page' ), "Testing page details";
eq_or_diff $tag, $pages->by_tag(
    tag => 'another'), "Testing pages tags";
eq_or_diff $list, $pages->search(
    pattern => 'Just' ), "Testing pages search";

done_testing;
