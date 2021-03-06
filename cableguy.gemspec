# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'palmade/cableguy/version'

Gem::Specification.new do |s|
  s.name        = "cableguy"
  s.version     = Palmade::Cableguy::VERSION
  s.authors     = ["Jan Mendoza"]
  s.email       = ["poymode@gmail.com"]
  s.homepage    = "https://github.com/poymode/cableguy"
  s.summary     = %q{Generate rails configurations from a sqlite key-value storage}
  s.description = %q{cableguy}

  s.rubyforge_project = "cableguy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
