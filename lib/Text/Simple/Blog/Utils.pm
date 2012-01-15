package Text::Simple::Blog::Utils;

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
        $class = "Text::Simple::Blog::Renderer::$r";
        load $class;
    }
    else {
        load Renderer;
        $class = 'Text::Simple::Blog::Renderer';
    }

    my $renderer = $class->new();

    return $renderer->renderer($text);
}

