# Spec helper for Rails-less tests

ENV["RAILS_ENV"] ||= 'test'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$:.unshift PROJECT_ROOT

require 'rspec/mocks'
require 'codeclimate-test-reporter'

CodeClimate::TestReporter.start if ENV['RAILS_ENV'] == 'testing'

TAG_DEFINITIONS_PATH = File.join(PROJECT_ROOT, 'config', 'tag_definitions.yml')
CATEGORY_RULES = File.join(PROJECT_ROOT, 'config', 'category_determination_rules.yml')
SCORING_RULES = File.join(PROJECT_ROOT, 'config', 'scoring_rules.yml')

def import_needed_shit
  #ActiveRecord::Base.connection.execute("delete from tags; delete from scoring_rules; delete from category_determination_rules;")
  import_tags
  import_category_rules
  import_scoring_rules
end

def import_tags
  tags = YAML::load_file(TAG_DEFINITIONS_PATH)
  tags.each do |tag_name, opts|
    t = Tag.new({
      name: tag_name,
      display_name: opts['display_name'],
      aliases: opts['aliases'],
      props: opts['props']
    })
    t.group_list = opts['group_list']
    t.save
  end
end

def import_category_rules
  rules = YAML::load_file(CATEGORY_RULES)
  rules.each do |category, scorings|
    CategoryDeterminationRule.create({:name => category, :scorings => scorings})
  end
end

def import_scoring_rules
    rules = YAML::load_file(SCORING_RULES)
    rules.each do |rule_config|
      ScoringRule.create(rule_config)
    end
end
