require 'rspec/core/rake_task'

# run these tasks in test environment
ENV['RAILS_ENV'] = "test"

namespace :test do
  
  desc "Runs rspec models tests"
  RSpec::Core::RakeTask.new(:models) do |t|
    t.pattern = FileList["spec/models"]
  end
  
  desc "Runs rspec library tests"
  RSpec::Core::RakeTask.new(:libs) do |t|
    t.pattern = FileList["spec/libs"]
  end

  desc "Runs rspec integration tests"
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = FileList["spec/integration_testing"]
    t.rspec_opts = "--order default"
  end
  
  namespace :services do
    desc "Runs rspec crawler service tests"
    RSpec::Core::RakeTask.new(:crawler) do |t|
      t.pattern = FileList["spec/services/crawler"]
    end
    
    desc "Runs rspec listener service tests"
    RSpec::Core::RakeTask.new(:listener) do |t|
      t.pattern = FileList["spec/services/listener"]
    end
    
    desc "Runs rspec irc_bot service tests"
    RSpec::Core::RakeTask.new(:irc_bot) do |t|
      t.pattern = FileList["spec/services/irc_bot"]
    end
    
    desc "Runs rspec xmpp_bot service tests"
    RSpec::Core::RakeTask.new(:xmpp_bot) do |t|
      t.pattern = FileList["spec/services/xmpp_bot"]
    end
  end

  desc "Runs all rspec unit tests"
  task :unit => ["test:models", "test:libs"]
  
end
