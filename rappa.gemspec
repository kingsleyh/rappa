# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rappa"
  s.version = "0.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kingsley Hendrickse"]
  s.date = "2013-11-22"
  s.description = "Easy and simple way to package up your rack based application into a .rap (Ruby Application Package) for deployment to a web container that supports .rap such as ThunderCat.\n"
  s.email = "kingsley@masterthought.net"
  s.executables = ["/rappa"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "src/rappa.rb","src/rap_validator.rb","src/property_validator.rb","src/rappa_error.rb"
  ]
  s.homepage = "https://github.com/masterthought/rappa"
  s.licenses = ["Apache 2.0"]
  s.require_paths = ["src"]
  s.rubygems_version = "1.8.25"
  s.summary = "Ruby Application Package Personal Assistant"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<configliere>, [">= 0"])
      s.add_runtime_dependency(%q<rubyzip>, [">= 0"])
      s.add_runtime_dependency(%q<jeweler>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<configliere>, [">= 0"])
      s.add_dependency(%q<rubyzip>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<configliere>, [">= 0"])
    s.add_dependency(%q<rubyzip>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0"])
  end
end

