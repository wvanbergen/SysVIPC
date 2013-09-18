# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'SysVIPC/version'

Gem::Specification.new do |s|
  s.name = 'SysVIPC'
  s.rubyforge_project = 'sysvipc'
  
  # Do not change the version and date fields by hand. This will be done
  # automatically by the gem release script.
  s.version = SysVIPC::VERSION

  s.summary     = "System V IPC bindings for Ruby"
  s.description = <<-EOT
    This is a fork of the SysVIPC gem
  EOT

  s.license  = 'GPL2'
  s.authors  = ['Willem van Bergen']
  s.email    = ['willem@railsdoctors.com']
  s.homepage = 'https://github.com/wvanbergen/SysVIPC'

  s.extensions    = ["ext/SysVIPC/extconf.rb"]
  s.require_paths = ["lib", "ext"]

  s.add_development_dependency('rake')
  s.add_development_dependency('rake-compiler')
  s.add_development_dependency('minitest', '~> 5')

  s.rdoc_options << '--title' << s.name << '--main' << 'README.rdoc' << '--line-numbers' << '--inline-source'
  s.extra_rdoc_files = ['README.rdoc']

  s.files = `git ls-files`.split($/)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
end
