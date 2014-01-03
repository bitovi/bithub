namespace :data do
  desc "Imports/updates category determination rules from YAML file"
  task :import_category_determination_rules => :environment do

    puts "---"
    puts "Importing/updating category determination rules"

    rules = YAML::load_file('config/category_determination_rules.yml')
    updated = []
    imported = []
    failed = []

    rules.each do |category, scorings|

      if existing = CategoryDeterminationRule.where({:name => category}).first
        existing.update_attributes({:scorings => scorings}) ? updated.push(category) : failed.push(category)
      else
        if CategoryDeterminationRule.create({:name => category, :scorings => scorings})
          imported.push(category)
        else
          failed.push(category)
        end
      end
      
    end

    puts "Summary:"
    puts "  #{imported.length} rules imported"
    puts "  #{updated.length} rules updated"
    puts "  #{failed.length} rules failed: #{failed.to_s}"

  end
end
