# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby-interface/version"

Gem::Specification.new do |s|
  s.name = %q{zactor}
  s.version = RubyInterface::VERSION
  s.summary = "Ruby interface"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Rudenko", "Nick Recobra"]
  s.date = %q{2011-03-24}
  s.description = %q{Ruby interface}
  s.email = %q{ceo@prepor.ru}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('activesupport', ["> 0.1"])
  s.add_dependency(%q<i18n>, ["> 0.1"])
end