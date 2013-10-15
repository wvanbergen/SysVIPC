# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'SysVIPC/version'

Gem::Specification.new do |s|
  s.name = 'SysVIPC'
  s.rubyforge_project = 'sysvipc'

  s.version = SysVIPC::VERSION

  s.summary     = "System V Inter-Process Communication for Ruby"
  s.description = <<-EOT
    Ruby extension that binds System V Inter-Process Communication:
    message queues, semaphores, and shared memory.
  EOT

  s.license  = 'GPL2'
  s.authors  = ['Steven Jenkins', 'Willem van Bergen']
  s.email    = ['steven.jenkins@ieee.org', 'willem@railsdoctors.com']
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
