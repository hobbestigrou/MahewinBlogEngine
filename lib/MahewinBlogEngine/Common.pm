package MahewinBlogEngine::Common;

use feature "state";

use Moo;
use Types::Path::Tiny qw/Path AbsPath/;
use Path::Tiny qw( path );

use CHI;
use MahewinBlogEngine::Renderer;

use Type::Params qw( compile );
use Types::Standard qw( slurpy Object Str HashRef ArrayRef );


=attr directory

rw, required, Str. The directory contain articles.

=cut

has 'directory' => (
    is       => 'rw',
    isa      => AbsPath,
    required => 1,
    coerce   => sub {
        my ( $dir ) = @_;

        return path($dir);
    }
);

=attr encoding

rw, Str. Indicate the encoding file. Default is utf8.

=cut

has 'encoding' => (
    is      => 'rw',
    isa     => Str,
    default => 'utf8'
);

=attr date_format

ro, Str. Date format used to display, POSIX strftime.
Default value is %x %T.

=cut

has 'date_format' => (
    is      => 'ro',
    isa     => Str,
    default => "%x %T"
);

has _last_file => (
    is       => 'rw',
    isa      => HashRef,
    default  => sub { {} },
    init_arg => undef,
);

has _renderer => (
    is       => 'lazy',
    isa      => Object,
    init_arg => undef,
);


has _cache => (
    is      => 'lazy',
    isa     => Object,
);

sub _build__renderer {
    return MahewinBlogEngine::Renderer->new();
}

sub _build__cache {
    return CHI->new( driver => 'Memory', global => 1 );
}

1;
