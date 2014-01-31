namespace :data do
  desc "Imports/updates scoring rules from YAML file"
  task :import_scoring_rules => :environment do

    puts "---"
    puts "Importing/updating scoring rules"
    
    rules = YAML::load_file('config/scoring_rules.yml')
    existing_rules = ScoringRule.all.each 
    
    updated = []
    imported = []
    failed = []
    
    rules.each do |rule|
      rule_tags = rule['required_tags']
      attrs = {
        required_tags: rule['required_tags'],
        ownership_value: rule['ownership_value'],
        award_value: rule['award_value'],
        upvote_value: rule['upvote_value']
      }

      if existing = ScoringRule.all.select {|r| r.required_tags.sort == rule_tags.sort}.first
        existing.assign_attributes(attrs)
        existing.save ? updated.push(rule_tags) : failed.push(rule_tags)
      else
        t = ScoringRule.new(attrs)
        t.save ? imported.push(rule_tags) : failed.push(rule_tags)
      end
    end
    
    puts "Summary:"
    puts "  #{imported.length} rules imported"
    puts "  #{updated.length} rules updated"
    puts "  #{failed.length} rules failed: #{failed.to_s}"

  end
end
