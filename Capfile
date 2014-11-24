# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/rails/migrations'
require 'capistrano/console'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

# Loads helper files
Dir.glob('lib/capistrano/**/*.rb').each { |r| import r }

require 'capistrano/npm'
set :npm_target_path, -> { release_path.join('public') }
set :npm_flags, '--production --silent'
set :npm_roles, :all

require 'capistrano/bower'
set :bower_flags, '--quiet --config.interactive=false'
set :bower_roles, :web
set :bower_target_path, -> { release_path.join('public') }
