require 'andand'
require 'core_ext'

module Accessors
  module General
    def extracted
      @data.andand[:extracted]
    end

    def meta
      @data.andand[:meta]
    end

    def feed
      @data.andand[:meta].andand[:feed]
    end

    def type
      @data.andand[:meta].andand[:type]
    end

    def content_digest
      @data.andand[:content_digest]
    end

    def source_data
      @data.andand[:source_data]
    end

    def feed_type
      [feed, type]
    end

    def url
      @data.andand[:extracted].andand[:url]
    end
  end

  module Bithub
  end

  module Blog
    def post_id
      @data.andand[:meta].andand[:post_id]
    end
  end

  module Disqus
    def post_id
      @data.andand[:meta].andand[:post_id]
    end
  end

  module Forum
    def url
      @data.andand[:extracted].andand[:url]
    end
  end

  module Github
    def issue_id
      @data.andand[:meta].andand[:issue_id]
    end

    def push_id
      @data.andand[:meta].andand[:push_id]
    end

    def repo_name
      @data.andand[:meta].andand[:repo_name]
    end

    def issue_number
      @data.andand[:meta].andand[:issue_number]
    end
  end

  module Twitter
  end
end

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

    init_type_mappings
    init_feed_mappings
    remap_feed_type
  end

  def remap_feed_type
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
  
  def method_missing(method, *args, &block)
    @data.send method, *args, &block
  end

  private
  def init_feed_mappings
    @feed_mappings = Hash.new(@data[:meta][:feed])
    @feed_mappings[:forums] = 'forum'
  end

  def init_type_mappings
    @type_mappings = Hash.new(@data[:meta][:type])
    @type_mappings[:status_event] = 'tweet'
    @type_mappings[:issues_event] = 'issue_event'
  end
end
