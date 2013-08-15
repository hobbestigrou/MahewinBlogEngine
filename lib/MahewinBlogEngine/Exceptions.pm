package MahewinBlogEngine::Exceptions;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw(throw_format_not_supported filename_not_parseable meta_not_valid);

use Exception::Class (
    'MahewinBlogEngine::Exception::FormatNotSupported' => {
        description => 'Format not supported',
        alias       => 'throw_format_not_supported',
    },
    'MahewinBlogEngine::Exception::FilenameNotParseable' => {
        description => 'The file name is not parseable',
        alias       => 'filename_not_parseable',
    },
    'MahewinBlogEngine::Exception::MetaNotValid' => {
        description => 'Meta of the file is not valid',
        alias       => 'meta_not_valid',
    }
);

1;
