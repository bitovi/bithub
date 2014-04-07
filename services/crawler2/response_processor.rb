require 'digest/md5'
require 'andand'
require 'sanitizer'

require 'core_ext'
require 'core_helpers'

class BasicTypeProcessor
  def initialize(response)
    @response = response
  end

  def decorate
  end
end

class ResponseProcessor

  class Configuration
    attr_accessor :term, :feed
    attr_writer :user_stream
    def user_stream?; @user_stream; end
  end

  def initialize(response, &blk)
    @config = Configuration.new
    blk.(@config) if blk

    @response = response
  end

  def parse
    @parsed ||= subprocessor.parse
    self
  rescue Yajl::ParseError => err
    @logger.error "Processor parsing error | #{err}"
    self
  end

  def extract
    @extracted ||= subprocessor.extract
    self
  end

  def decorate
    @decorated ||= result.map do |event_hash|
      event_instance(event_hash)
    end.reject do |event|
      tweet_from_user_stream?(event)
    end.map do |event|
      event.to_hash.deep_merge(subprocessor.decorate)
    end
    self
  end

  def result
    @decorated || @extracted || @parsed
  end

  private

  def tweet_from_user_stream?(event)
    event.nice_name =~ /Tweet/ && @config.user_stream?
  end

  def event_instance(event_hash)
    Events::Dispatcher.dispatch(event_hash, @config.feed)
  end

  def subprocessor
    @subprocessor ||= Events::Dispatcher.feed(@response, @config.feed)::Processor.new(@response) do |config|
      config.term = @config.term if config.respond_to? :term=
      config.user_stream = @config.user_stream? if config.respond_to? :user_stream=
    end
  end
end

module Forum
  class Processor
    class Configuration
      attr_accessor :term
    end

    def initialize(response, &blk)
      @config = Configuration.new
      blk.(@config) if blk

      @response = response
    end

    def parse
      @parsed ||= Nori.new(:parser => :nokogiri).parse(@response)
    end

    def extract
      @extracted ||= parse['rss']['channel']['item']
    end

    def decorate
      { meta: { term: [@config.term] }}
    end
  end
end

module Twitter
  class Processor
    attr_reader :parsed, :extracted

    class Configuration
      attr_writer :user_stream
      def user_stream?
        @user_stream
      end
    end

    def initialize(response, &blk)
      @config = Configuration.new
      blk.(@config) if blk
      @response = response
    end

    def parse
      @parsed ||= Yajl::Parser.parse(@response)
    end

    def extract
      @extracted ||= [parse]
    end

    def decorate
    end

    private
    def user_stream?
      @config.user_stream?
    end

    def public_stream?
      not(user_stream?)
    end
  end
end


module Github
  class Processor < BasicTypeProcessor
    def parse
      @parsed ||= Yajl::Parser.parse(@response)
    end

    def extract
      parse
    end
  end
end

module Meetup
  class Processor < BasicTypeProcessor
    def parse
      @parsed ||= Yajl::Parser.parse(@response)
    end

    def extract
      @extracted ||= parse['results']
    end
  end
end

module StackExchange
  class Processor < BasicTypeProcessor
    def parse
      @parsed ||= Yajl::Parser.parse(@response)
    end

    def extract
      @extracted = parse['items']
    end
  end
end

module Disqus
  class Processor < BasicTypeProcessor
    def parse
      @parsed ||= Yajl::Parser.parse(@response)
    end

    def extract
      @extracted = parse['response']
    end
  end
end

module Blog
  class Processor < BasicTypeProcessor
    def parse
      @parsed ||= Nori.new(:parser => :nokogiri).parse(@response)
    end

    def extract
      @extracted ||= parse['rss']['channel']['item']
    end
  end
end
