# -*- ruby -*-

$LOAD_PATH.unshift('lib')

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/binary_finery.rb"
end

task :default => :test

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.pattern = 'test/**/{helper,test_*}.rb'
  test.warning = true
  test.verbose = true
end


