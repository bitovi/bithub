namespace :data do
  desc "Imports/updates scoring rules from YAML file"
  task :import_scoring_rules => :environment do

    Rails.logger.info "---"
    Rails.logger.info "Importing scoring rules"

    if tenant = ENV['TENANT']
      Apartment::Database.switch tenant
      Rails.logger.info "Tenant switched to '#{Apartment::Database.current_tenant}'"
    end

    rules = YAML::load_file('config/scoring_rules.yml')

    def exists?(required_tags)
      ScoringRule
        .pluck(:required_tags)
        .map {|r| (r.is_a?(String)) ? HstoreDeserializer.new(r).parse : r}
        .select{|r| r.keys.sort == required_tags.keys.sort}
        .count > 0
    end

    rules.each do |rule|
      rule['authorship_value'] ||= 0
      rule['award_value'] ||= 0
      rule['upvote_value'] ||= 1

      required_tags = Tagger.list_to_name_weight_hash rule['required_tags']

      if exists? required_tags
        Rails.logger.info "Rule '#{rule['name']}' already exists!"
      else
        if ar_rule = ScoringRule.create(rule)
          Rails.logger.info "Rule '#{rule['name']}' created"
        else
          Rails.logger.info "Rule '#{rule['name']}' failed"
        end
      end
    end

  end
end
