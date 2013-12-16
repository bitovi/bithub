require 'yajl'
require 'nokogiri'
require 'nori'

require 'core_ext'
require 'processing/processor'

class ResponseLoader
  ROOT = 'spec/support/responses'

  def initialize(endpoint = 'events')
    @endpoint = endpoint
    @processors = {}
  end

  def parsed_and_processed_response(feed, type)
    process(parse(raw(type, feed), feed), feed)
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
      Yajl::Parser.parse(raw)
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

  def processor(feed)
    @processors[feed] ||= Processing::Processor.new(feed)
  end


  # Aliases

  alias_method :ppr, :parsed_and_processed_response
  alias_method :pr, :parsed_response
  alias_method :r, :response
end
