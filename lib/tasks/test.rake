require 'rspec/core/rake_task'

# Run these tasks in test environment
ENV['RAILS_ENV'] = "test"

task :default => :test
task :test => %w(test:domain)

1namespace :test do

  RSpec::Core::RakeTask.new(:domain) do |t|
    t.pattern = FileList["spec/domain"]
  end

  RSpec::Core::RakeTask.new(:models) do |t|
    t.pattern = FileList["spec/models"]
  end

  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = FileList["spec/integration"]
    t.rspec_opts = "--order default"
  end

  # namespace :services do
  #   desc "Runs rspec crawler service tests"
  #   RSpec::Core::RakeTask.new(:crawler) do |t|
  #     t.pattern = FileList["spec/services/crawler"]
  #   end

  #   desc "Runs rspec listener service tests"
  #   RSpec::Core::RakeTask.new(:listener) do |t|
  #     t.pattern = FileList["spec/services/listener"]
  #   end

  #   desc "Runs rspec irc_bot service tests"
  #   RSpec::Core::RakeTask.new(:irc_bot) do |t|
  #     t.pattern = FileList["spec/services/irc_bot"]
  #   end

  #   desc "Runs rspec xmpp_bot service tests"
  #   RSpec::Core::RakeTask.new(:xmpp_bot) do |t|
  #     t.pattern = FileList["spec/services/xmpp_bot"]
  #   end
  # end
end
