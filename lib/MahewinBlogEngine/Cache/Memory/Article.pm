package MahewinBlogEngine::Cache::Memory::Article;

use Moose;

has title => (
    is  => 'ro',
    isa => 'Str',
);

has tags => (
    is  => 'ro',
    isa => 'ArrayRef',
);

has date => (
    is  => 'ro',
    isa => 'Str',
);

has epoch => (
    is  => 'rw',
    isa => 'Int',
);

has content => (
    is  => 'ro',
    isa => 'Str',
);

has link => (
    is  => 'ro',
    isa => 'Str',
);

1;


__END__


=head1 SYNOPSIS

# synopsis...

=head1 DESCRIPTION

# longer description...


