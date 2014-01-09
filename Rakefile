#!/usr/bin/env rake

if ENV['ENV'] == 'test'
  $:.unshift File.dirname(File.expand_path(__FILE__))
  load 'lib/tasks/test.rake'
else
  # Add your own tasks in files placed in lib/tasks ending in .rake,
  # for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
  require File.expand_path('../config/application', __FILE__)
  Bithub::Application.load_tasks
end
