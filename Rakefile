require "bundler/gem_tasks"
require "rake/extensiontask"
require "rake/testtask"

Rake::ExtensionTask.new('SysVIPC') do |ext|
  ext.lib_dir = File.join('lib', 'SysVIPC')
  ext.config_options = '--with-cflags="-std=c99"'
end

Rake::TestTask.new(:test) do |t|
  t.test_files = Dir.glob('test/**/*_test.rb')
  t.libs << 'test'
end

task :test => [:compile]
task :default => [:test]
