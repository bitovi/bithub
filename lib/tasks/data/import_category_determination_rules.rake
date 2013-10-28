namespace :data do
  desc "Imports category determination rules from YAML file"
  task :import_category_determination_rules => :environment do
    rules = YAML::load_file('config/category_determination_rules.yml')

    rules.each do |category, scorings|
      if CategoryDeterminationRule.new({:name => category, :scorings => scorings}).save!
        puts "[SAVED]  Rule #{scorings} for category '#{category}'"
      end
    end

  end
end
