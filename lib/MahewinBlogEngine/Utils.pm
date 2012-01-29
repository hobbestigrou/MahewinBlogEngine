package MahewinBlogEngine::Utils;

use strict;
use warnings;

use Module::Load;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(converted_text);

sub converted_text {
    my ( $text, $format ) = @_;

    my $dispatch = {
        md   => 'Markdown',
        html => 'HTML'
    };

    my $r = $dispatch->{$format} || '';
    my $class;

    if ( $r ) {
        $class = "MahewinBlogEngine::Renderer::$r";
        load $class;
    }
    else {
        $class = 'MahewinBlogEngine::Renderer';
        load $class;
    }

    my $renderer = $class->new();

    return $renderer->renderer($text);
}

