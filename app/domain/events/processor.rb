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
    end

    def initialize(response, &blk)
      initialize_logger("DEBUG")

      @config = Configuration.new
      blk.(@config) if blk

      @feed = @config.feed
      @response = response
    end
    
    def parse
      @parsed ||= subprocessor.parse
      self
    end

    def extract
      @extracted ||= subprocessor.extract
      self
    end

    def decorate
      begin
        @decorated ||= result.map do |event_hash|
          e = Events::Dispatcher.dispatch(event_hash, @feed)
          e.to_json.deep_merge(subprocessor.decorate)
        end
      rescue Events::InvalidDigestSeed => err
        @logger.error "#{err.message} | #{err.source_data}"
      end

      self
    end

    def result
      @decorated || @extracted || @parsed
    end

    private
    
    def subprocessor
      @subprocessor ||= Events.feed(@feed)::Processor.new(@response) do |config|
        config.term = @config.term
      end
    end
  end

end
