package Jedi::Plugin::Session::Backend::SQLite::DB;

# ABSTRACT: Schema for SQLite Session

use strict;
use warnings;

our $VERSION = 1; #Schema Version

use base qw/DBIx::Class::Schema/;
 
__PACKAGE__->load_classes({
  __PACKAGE__ . '::Result' => [qw/Session/]
});

1;