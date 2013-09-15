package MahewinBlogEngine::Article;

use Moo;

use Type::Params qw( compile );
use Type::Utils;
use Types::Standard qw( Object Str Int ArrayRef );

has title => (
    is       => 'rw',
    isa      => Str,
    required => 1,
);

has tags  => (
    is       => 'rw',
    isa      => ArrayRef,
    required => 1,
);

has date  => (
    is       => 'rw',
    isa      => Object,
    required => 1,
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

1;
