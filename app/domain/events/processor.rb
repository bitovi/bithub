require 'digest/md5'
require 'andand'

require 'core_ext'
require 'core_helpers'
require 'loggable'

require 'events/dispatcher'

module Events
  class Processor
    include Loggable

    class Configuration
      attr_accessor :term, :feed
      attr_writer :user_stream
      def user_stream?; @user_stream; end
    end

    def initialize(response, &blk)
      initialize_logger("INFO")

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
        e = Events::Dispatcher.dispatch(event_hash, @config.feed)
        e.to_json.deep_merge(subprocessor.decorate)
      end
      self
    end

    def result
      @decorated || @extracted || @parsed
    end

    private
    
    def subprocessor
      @subprocessor ||= Events.feed(@config.feed)::Processor.new(@response) do |config|
        config.term = @config.term if config.respond_to? :term=
        config.user_stream = @config.user_stream? if config.respond_to? :user_stream=
      end
    end
  end

end
