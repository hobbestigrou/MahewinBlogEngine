use strict;
use warnings;

use Test::More tests => 1;                      # last test to print


BEGIN {
    use_ok( 'MahewinBlogEngine' ) || print "Bail out";
}

diag( "Testing MahewinBlogEngine $MahewinBlogEngine::VERSION, Perl $], $^X" );
