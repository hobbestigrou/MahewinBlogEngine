package MahewinBlogEngine::Comment;

use Moo;

use Type::Params qw( compile );
use Type::Utils;
use Types::Standard qw( Object Str Int ArrayRef );

has author => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has mail  => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has date  => (
    is       => 'rw',
    isa      => Object,
    required => 1,
);

has hidden  => (
    is       => 'ro',
    isa      => Int,
    default  => sub { return 1; },
);

has content => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has link => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has link_article => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

1;
