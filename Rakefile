#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be
# available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'cane/rake_task'

SchedDo::Application.load_tasks

desc 'Run cane to check quality metrics'

Cane::RakeTask.new(:quality) do |cane|
  cane.abc_max = 10
  cane.add_threshold 'coverage/.last_run.json', :>=, 95
  cane.no_doc = true
  cane.parallel = true
end

if defined?(RSpec)
  desc 'Run factory specs'

  RSpec::Core::RakeTask.new(:factory_specs) do |test|
    test.pattern = './spec/factories_spec.rb'
  end

  desc 'Run acceptance specs'

  RSpec::Core::RakeTask.new(:acceptance) do |test|
    test.pattern = 'spec/acceptance/**/*.feature'
  end
end

task spec: :factory_specs
task(:default).clear
task :default => [:quality, :spec, :acceptance, 'spec:javascripts']
