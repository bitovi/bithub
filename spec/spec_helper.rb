# Spec helper for Rails-less tests

ENV["RAILS_ENV"] ||= 'test'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$:.unshift PROJECT_ROOT

require 'rspec/mocks'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start if ENV['RAILS_ENV'] == 'testing'

TAG_DEFINITIONS_PATH = File.join(PROJECT_ROOT, 'tag_definitions.yml')

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
