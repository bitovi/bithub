require 'spec_helper'
require 'yaml'

TAG_DEFINITIONS_PATH = './config/tag_definitions.yml'

def import_tags
  tags = YAML::load_file(@tag_definitions_path)
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
