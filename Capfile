# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/bundler'
require 'capistrano/rails/migrations'
require 'capistrano/console'

# Record a deploy when it happens (for comparing perf. across deploys)
require 'new_relic/recipes'

# Export recurring tasks to crontab
require "whenever/capistrano"

Dir.glob('config/capistrano/tasks/*.cap').each { |r| import r }
Dir.glob('config/capistrano/helpers/*.rb').each { |r| import r }
