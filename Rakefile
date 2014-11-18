#!/usr/bin/env rake

require 'rainbow/ext/string'

desc 'Run tests'
task :build do
  # Fail the build only for correctness
  #
  puts "\nRunning foodcritic".color(:blue)
  sh 'foodcritic --chef-version 11.10 --tags ~FC001 --tags ~FC004 --epic-fail correctness cookbooks/pelias'

  # Check ruby syntax
  #
  puts 'Running rubocop'.color(:blue)
  sh 'rubocop cookbooks/pelias .'
end

task default: 'build'
