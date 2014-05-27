namespace :data do
  desc "Imports/updates category determination rules from YAML file"
  task :import_category_determination_rules => :environment do

    puts "---"
    puts "Importing category determination rules"

    rules = YAML::load_file('config/category_determination_rules.yml')

    def exists?(required_tags)
      CategoryDeterminationRule
        .pluck(:required_tags)
        .select {|r| r.keys.sort == required_tags.keys.sort}
        .count > 0
    end

    rules.each do |rule|
      if exists?(rule['required_tags'])
        puts "Rule '#{rule['name']}' already exists!"
      else
        if ar_rule = CategoryDeterminationRule.create(rule)
          puts "Rule '#{rule['name']}' imported --> #{ar_rule.inspect}"
        else
          puts "Rule '#{rule['name']}' failed!"
        end
      end
    end

  end
end
