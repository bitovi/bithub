require 'bundler/capistrano'
set :bundle_flags, "--deployment --quiet --binstubs"

set :application, "irc-bot"
set :repository,  "git@github.com:jupiterjs/irc-bot.git"

role :web, "69.164.216.88"
role :app, "69.164.216.88"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
