#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Differences::Color;

use Cwd;
use MahewinBlogEngine;

my $articles = MahewinBlogEngine->articles(
    directory => getcwd() . '/t/articles'
);
my $list     = [{
        content => '<h1>Introduction</h1>

<p>Just a file to test the textile format.</p>',
        link  => 'test_textile_format',
        epoch => 1356897600,
        date  => '30/12/2012 20:00:00',
        title => 'Test textile format
',
        tags => [
            'format',
            ' textile
'
        ]
    },
    {
        content => '<h1>Introduction</h1>

<p>Just a file to test pod format.</p>
',

        link  => 'test_pod_format',
        epoch => 1356801300,
        date  => '29/12/2012 17:15:00',
        title => 'Test pod format
',
        tags => [
            'pod',
            ' format
'
        ]
    },
    {
        content => '<p>To test footnote feature with multimarkdown.<a href="#fn:1" id="fnref:1" class="footnote">1</a></p>

<div class="footnotes">
<hr />
<ol>

<li id="fn:1"><p>This is the footnote.<a href="#fnref:1" class="reversefootnote">&#160;&#8617;</a></p></li>

</ol>
</div>
',
    date => '28/12/2012 19:15:00',
    epoch => 1356722100,
    link => 'test_footnotes',
    tags => [
    'footnote',
    ' multimarkdown
'
    ],
    title => 'Test footnotes
'
},

    {
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
