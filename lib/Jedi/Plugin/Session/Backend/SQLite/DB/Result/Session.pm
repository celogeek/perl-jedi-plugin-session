package Jedi::Plugin::Session::Backend::SQLite::DB::Result::Session;

# ABSTRACT: ResultSet for Session table

use strict;
use warnings;
# VERSION

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('jedi_session');
__PACKAGE__->add_columns(qw/id expire_at session/);
__PACKAGE__->set_primary_key('id');

1;