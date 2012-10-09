package MahewinBlogEngine::Cache::Memory::Comment;

use Moose;

has author => (
    is  => 'ro',
    isa => 'Str',
);

has mail => (
    is  => 'ro',
    isa => 'Str',
);

has url => (
    is  => 'ro',
    isa => 'Str',
);

has hidden => (
    is  => 'ro',
    isa => 'Int',
);

has url_article => (
    is  => 'ro',
    isa => 'Str',
);

has body => (
    is  => 'ro',
    isa => 'Str',
);

1;
