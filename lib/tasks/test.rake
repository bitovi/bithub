require 'rspec/core/rake_task'

ENV['RAILS_ENV'] = "test"

namespace :test do

  RSpec::Core::RakeTask.new(:domain) do |t|
    t.pattern = FileList["spec/domain"]
  end

  RSpec::Core::RakeTask.new(:models) do |t|
    t.pattern = FileList["spec/models"]
  end
  
  RSpec::Core::RakeTask.new(:libs) do |t|
    t.pattern = FileList["spec/libs"]
  end

end

task :test => %w(test:domain test:models test:libs)
task :default => :test
