require "bundler/gem_tasks"
require "rake/extensiontask"

Dir['tasks/*.rake'].each { |file| load(file) }

Rake::ExtensionTask.new('SysVIPC') do |ext|
  ext.lib_dir = File.join('lib', 'SysVIPC')
  ext.config_options = '--with-cflags="-std=c99"'
end

task :default => [:compile]
