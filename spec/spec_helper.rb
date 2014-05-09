# Spec helper for Rails-less tests

ENV["RAILS_ENV"] ||= 'test'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.expand_path("#{PROJECT_ROOT}/config/environment", __FILE__)
$:.unshift PROJECT_ROOT

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start if ENV['RAILS_ENV'] == 'test'

require 'rspec/mocks'
require 'rspec/rails'

# ----------
# VCR config
# ----------

# VCR.configure do |c|
#   c.cassette_library_dir = 'fixtures/vcr_cassettes'
#   c.hook_into :webmock
# end

# ---------------
# Tag definitions
# ---------------

TAG_DEFINITIONS_PATH = File.join(PROJECT_ROOT, 'config', 'tag_definitions.yml')
CATEGORY_RULES_PATH = File.join(PROJECT_ROOT, 'config', 'category_determination_rules.yml')
SCORING_RULES_PATH = File.join(PROJECT_ROOT, 'config', 'scoring_rules.yml')

def import_all
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
  rules = YAML::load_file(CATEGORY_RULES_PATH)
  rules.each do |category, scorings|
    CategoryDeterminationRule.create({:name => category, :scorings => scorings})
  end
end

def import_scoring_rules
  rules = YAML::load_file(SCORING_RULES_PATH)
  rules.each do |rule_config|
    ScoringRule.create(rule_config)
  end
end


# ----------------
# Response loading
# ----------------

def load_and_parse(path)
  ext_name = File.extname(path).gsub('.','').to_sym

  loaders = {
    json: lambda {|p| ActiveSupport::JSON.decode(File.read(path)) },
    rss: lambda {|p| Nori.new(:parser => :nokogiri).parse(File.read(path)) }
  }

  loaders[ext_name].(path)
end

def raw_data(opts = {})
  load_and_parse File.join('spec/support/responses', opts[:response_path])
end
