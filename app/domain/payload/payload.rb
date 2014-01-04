require 'andand'
require 'core_ext'
require 'payload/errors'
require 'payload/accessors'

class Payload
  include Accessors::General
  include Accessors::Bithub
  include Accessors::Blog
  include Accessors::Disqus
  include Accessors::Forum
  include Accessors::Github
  include Accessors::Twitter

  def initialize(hash)
    @data = hash.symbolize_keys
    verify_critical_attrs
    initialize_mappings
    remap_feed_and_type
  end

  def remap_feed_and_type
    @data[:meta][:feed] = @feed_mappings[@data[:meta][:feed]]
    @data[:meta][:type] = @type_mappings[@data[:meta][:type]]
  end

  def switch_to_camel_case
    @data[:meta][:feed] = feed.camel_case
    @data[:meta][:type] = type.camel_case
    self
  end

  def switch_to_snake_case
    @data[:meta][:feed] = feed.snake_case
    @data[:meta][:type] = type.snake_case
    self
  end

  def ==(other)
    @data == other
  end

  def raw
    @data
  end
  
  private
  def verify_existance_of_critical_attributes
    fail MissingFeedError unless self.feed
    fail MissingTypeError unless self.type
  end

  def initialize_mappings
    @feed_mappings = Hash.new(@data[:meta][:feed])
    @feed_mappings[:forums] = 'forum'

    @type_mappings = Hash.new(@data[:meta][:type])
    @type_mappings[:status_event] = 'tweet'
    @type_mappings[:issues_event] = 'issue_event'
  end
end
