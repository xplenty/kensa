# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "xplenty/kensa/version"

Gem::Specification.new do |s|
  s.name = %q{xplenty-kensa}
  s.version = Xplenty::Kensa::VERSION
  s.platform = Gem::Platform::RUBY

  s.authors = ["Blake Mizerany", "Pedro Belo", "Adam Wiggins", 'Glenn Gillen', 'Chris Continanza', 'Matthew Conway', 'Moty Michaely']
  s.default_executable = %q{kensa}
  s.description = %q{Kensa is a command-line tool to help add-on providers integrating their services with Xplenty. It manages manifest files, and provides a TDD-like approach for programmers to test and develop their APIs.}
  s.email = %q{moty@xplenty.com}

  s.rubyforge_project = "xplenty-kensa"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.homepage = %q{http://www.xplenty.com}
  s.rubygems_version = %q{1.4.4}
  s.summary = %q{Tool to help Xplenty add-on providers integrating their services}

  s.add_development_dependency(%q<artifice>, [">= 0"])
  s.add_development_dependency(%q<contest>, [">= 0"])
  s.add_development_dependency(%q<contest>, [">= 0"])
  s.add_development_dependency(%q<coveralls>)
  s.add_development_dependency(%q<fakefs>, [">= 0"])
  s.add_development_dependency(%q<haml>, [">= 0"])
  s.add_development_dependency(%q<rr>, [">= 0"])
  s.add_development_dependency(%q<sinatra>, [">= 0.9"])
  s.add_development_dependency(%q<timecop>, [">= 0.3.5"])
  s.add_runtime_dependency(%q<launchy>, [">= 0.3.2"])
  s.add_runtime_dependency(%q<mechanize>, ["~> 2.6.0"])
  s.add_runtime_dependency(%q<rest-client>, ["< 1.7.0", ">= 1.4.0"])
  s.add_runtime_dependency(%q<term-ansicolor>, ["~> 1.0"])
end