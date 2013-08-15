package MahewinBlogEngine::Common;

use feature "state";

use Moo;
use Types::Path::Tiny qw/Path AbsPath/;
use Path::Tiny qw( path );

use CHI;

use MahewinBlogEngine::Renderer;
use MahewinBlogEngine::Exceptions;

use Type::Params qw( compile );
use Type::Utils;
use Types::Standard qw( slurpy Object Dict Str HashRef ArrayRef );

my $invocant = class_type { class => __PACKAGE__ };

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

before _get_or_create_cache => sub {
    my ($self, $type) = @_;

    foreach my $file ( $self->directory->children ) {
        if ( exists $self->_last_file->{$file} ) {
            while ( my ( $key, $value ) = each %{ $self->_last_file } ) {
                my $stat = $file->stat;
                if ( $key eq $file ) {
                    if ( $stat->[9] != $value ) {
                        $self->_last_file->{$file} = $stat->[9];
                        $self->_cache->remove($type);
                    }
                }
            }
        }
        else {
            $self->_cache->remove($type);
        }
    }

    return;
};

sub _build__renderer {
    return MahewinBlogEngine::Renderer->new();
}

sub _build__cache {
    return CHI->new( driver => 'Memory', global => 1 );
}

sub _get_or_create_cache {
    my ( $self, $type ) = @_;

    my $cache = $self->_cache->get($type);

    if ( !defined($cache) ) {
        my @articles = $self->_inject_article;
        $self->_cache->set( $type, \@articles );
        $cache = $self->_cache->get($type);
    }

    return $cache;
}

sub _validate_meta {
    my ($self, @file_content) = @_;

    if (   $file_content[0] !~ m/^Title:\s+\w+/
        || $file_content[1] !~ m/^Tags:(?:\s\w+)/ )
    {
        meta_not_valid error => 'Meta not valid';
    }

    return;
}

sub details {
    state $check = compile(
        $invocant,
        slurpy Dict[
            type => Str,
            link => Str,
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $type         = $arg->{type};
    my $url          = $arg->{link};

    foreach my $data ( @{ $self->_get_or_create_cache($type) } ) {
        return $data if $data->{link} eq $url;
    }

    return;
}

sub by_tag {
    state $check = compile(
        $invocant,
        slurpy Dict[
            type => Str,
            tag  => Str,
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $type         = $arg->{type};
    my $tag          = $arg->{tag};

    my @list;
    foreach my $data ( @{ $self->_get_or_create_cache($type) } ) {
        push( @list, $data ) if grep( /$tag/, @{ $data->{tags} } );
    }

    return \@list;
}

sub search {
    state $check = compile(
        $invocant,
        slurpy Dict[
            type    => Str,
            pattern => Str,
        ]
    );
    my ($self, $arg) = $check->(@_);
    my $type         = $arg->{type};
    my $str          = $arg->{pattern};

    my @results;
    foreach my $data ( @{ $self->_get_or_create_cache($type) } ) {
        if ( $data->{title} =~ /$str/i || $data->{content} =~ /$str/i ) {
            push( @results, $data );
        }
    }

    return \@results;
}

1;
