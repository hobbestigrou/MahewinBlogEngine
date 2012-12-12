package MahewinBlogEngine::Common;

use Moose;
use MooseX::Types::Path::Class qw(Dir File);

use CHI;
use MahewinBlogEngine::Renderer

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

=attr date_format

ro, Str. Date format used to display, POSIX strftime.
Default value is %x %T.

=cut

has 'date_format' => (
    is      => 'ro',
    isa     => 'Str',
    default => "%x %T"
);

has _last_file => (
    is       => 'rw',
    isa      => 'HashRef',
    default  => sub { {} },
    init_arg => undef,
);

has _renderer => (
    is      => 'ro',
    isa     => 'MahewinBlogEngine::Renderer',
    lazy    => 1,
    builder => '_build_renderer',
);


has _cache => (
    is      => 'ro',
    isa     => 'CHI::Driver',
    lazy    => 1,
    builder => '_build_cache',
);

sub _build_renderer {
    return MahewinBlogEngine::Renderer->new();
}

sub _build_cache {
    return CHI->new( driver => 'Memory', global => 1 );
}

1;
