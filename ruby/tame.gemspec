Gem::Specification.new do |s|
  s.name = 'tame'
  s.version = '1.0.0'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG", "MIT-LICENSE"]
  s.rdoc_options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'tame: restrict system operations on OpenBSD', '--main', 'README.rdoc']
  s.summary = "Restrict system operations on OpenBSD"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.homepage = "https://github.com/jeremyevans/tame_libs/tree/master/ruby"
  s.required_ruby_version = ">= 1.8.7"
  s.files = %w(MIT-LICENSE CHANGELOG README.rdoc Rakefile ext/tame/extconf.rb ext/tame/tame.c)
  s.license = 'MIT'
  s.extensions << 'ext/tame/extconf.rb'
  s.description = <<END
tame exposes OpenBSD's tame(2) system call to ruby, allowing a
program to restrict the types of operations the program
can do after that point.  Unlike other similar systems,
tame is specifically designed for programs that need to
use a wide variety of operations on initialization, but
a fewer number after initialization (when user input will
be accepted).
END
end
