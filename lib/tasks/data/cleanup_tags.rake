namespace :data do
  desc "Cleans uneeded tags of any kind"
  task :cleanup_tags=> :environment do
    Rake::Task["data:cleanup_junk_tags"].execute
    Rake::Task["data:cleanup_tag_duplicates"].execute
  end
end
