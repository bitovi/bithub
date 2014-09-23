require 'rspec/core/rake_task'

ENV['RAILS_ENV'] ||= "test"
ActiveRecord::Migration.maintain_test_schema!
namespace :test do

  RSpec::Core::RakeTask.new(:models) do |t|
    t.pattern = FileList["spec/models"]
  end

  RSpec::Core::RakeTask.new(:libs) do |t|
    t.pattern = FileList["spec/libs"]
  end

  RSpec::Core::RakeTask.new(:services) do |t|
    t.pattern = FileList["spec/services"]
  end
end

task :test => %w(test:models test:libs test:services)
task :default => :test
