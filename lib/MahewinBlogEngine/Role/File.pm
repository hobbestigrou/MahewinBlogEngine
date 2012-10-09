package MahewinBlogEngine::Role::File;

use Moose::Role;
use MooseX::Types::Path::Class qw(Dir File);

use MahewinBlogEngine::Cache::Memory;

=attr directory

rw, required, Str. The directory contain articles.

=cut

has 'directory' => (
    is       => 'rw',
    isa      => Dir,
    required => 1,
    coerce   => 1,
);

=attr encoding

rw, Str. Indicate the encoding file. Default is utf8.

=cut

has 'encoding' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'utf8'
);

has _cache => (
    is      => 'ro',
    isa     => 'MahewinBlogEngine::Cache::Memory',
    lazy    => 1,
    builder => '_build_cache',
);

sub _build_cache {
    return MahewinBlogEngine::Cache::Memory->new;
}

1;
