require 'mkmf'
have_header 'tame'
$CFLAGS << " -O0 -g -ggdb" if ENV['DEBUG']
create_makefile("tame")
