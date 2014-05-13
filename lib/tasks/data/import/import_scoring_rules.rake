namespace :data do
  desc "Imports/updates scoring rules from YAML file"
  task :import_scoring_rules => :environment do

    puts "---"
    puts "Importing scoring rules"

    rules = YAML::load_file('config/scoring_rules.yml')

    def exists?(required_tags)
      ScoringRule
        .pluck(:required_tags)
        .select {|r| r.keys.sort == required_tags.keys.sort}
        .count > 0
    end

    rules.each do |rule|
      if exists?(rule['required_tags'])
        puts "Rule '#{rule['name']}' already exists!"
      else
        if ar_rule = ScoringRule.create(rule)
          puts "Rule '#{rule['name']}' created --> #{ar_rule.inspect}"
        else
          puts "Rule '#{rule['name']}' failed!"
        end
      end
    end

  end
end
