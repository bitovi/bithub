require 'nokogiri'
require 'nori'

require 'core_ext'

class ResponseLoader
  ROOT = 'spec/support/responses'

  def initialize(endpoint = 'events')
    @endpoint = endpoint
    @processors = {}
  end

  def parsed_response(feed, type)
    parsed(raw(type, feed), feed)
  end

  def response(feed, type)
    raw type feed
  end

  def process(payload, feed)
    processor(feed).process(payload)
  end

  def parse(raw, feed)
    if %w(blog forums).include? feed
      Nori.new(:parser => :nokogiri).parse(raw).first
    else
      JSON.parse(raw)
    end
  end

  def raw(type, feed)
    if %w(blog forums).include? feed
      path = File.join(ROOT, feed, type.snake_case + '.rss')
    elsif feed == 'github'
      path = File.join(ROOT, feed, @endpoint, type.snake_case + '.json')
    else
      path = File.join(ROOT, feed, type.snake_case + '.json')
    end

    File.read(path)
  end


  # Aliases
  alias_method :pr, :parsed_response
  alias_method :r, :response
end
