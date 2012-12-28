#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Differences::Color;

use Cwd;
use MahewinBlogEngine;

my $articles = MahewinBlogEngine->articles( directory => getcwd() . '/t/articles' );
my $list     = [{
  content => '<p>Just a another test article.</p>
',
  date => '27/12/2012 17:15:00',
  epoch => 1356628500,
  link => 'another_test_article',
  tags => [
    'test',
    ' article
'
  ],
  title => 'Another test article
'
},
    {
    link    => 'hello_world',
    epoch   => 1356603300,
    date    => '27/12/2012 10:15:00',
    content => '<p>Just a simple hello world.</p>
',
    title   => 'Hello world
',
    tags    => [
        'Hello
']
}];
my $details = {
    link    => 'hello_world',
    epoch   => 1356603300,
    date    => '27/12/2012 10:15:00',
    content => '<p>Just a simple hello world.</p>
',
    title   => 'Hello world
',
    tags    => [
        'Hello
']
};
my $tags = [{
  content => '<p>Just a another test article.</p>
',
  date => '27/12/2012 17:15:00',
  epoch => 1356628500,
  link => 'another_test_article',
  tags => [
    'test',
    ' article
'
  ],
  title => 'Another test article
'
}];
my $search = [{
    link    => 'hello_world',
    epoch   => 1356603300,
    date    => '27/12/2012 10:15:00',
    content => '<p>Just a simple hello world.</p>
',
    title   => 'Hello world
',
    tags    => [
        'Hello
']
}];

eq_or_diff $list, $articles->article_list, "Testing articles list";
eq_or_diff $details, $articles->article_details(
    link => 'hello_world' ), "Testing article details";
eq_or_diff $tags, $articles->article_by_tag(
    tag => 'test'), "Testing articles tags";
eq_or_diff $search, $articles->search(
    pattern => 'world' ), "Testing articles search";

done_testing;
