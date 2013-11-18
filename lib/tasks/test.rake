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
  end

  desc "Runs all rspec unit tests"
  task :unit => ["test:models", "test:libs"]
  
end
