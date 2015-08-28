#!/usr/bin/env rake

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../config/application', __FILE__)

Bithub::Application.load_tasks

# We keep our tasks in app/tasks becuase tasks are a part of our app
Dir.glob('app/tasks/**/*.rake').each { |r| load r}
