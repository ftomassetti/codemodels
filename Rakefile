require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

Gem::Tasks.new do |tasks|
  tasks.console.command = 'jruby'
end

desc "Run tests"
task :default => :test