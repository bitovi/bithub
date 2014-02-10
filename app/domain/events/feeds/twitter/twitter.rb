module Events
  module Twitter
    class Tweet < Protocol; end
    class Follow < Protocol; end
    class CustomFollow < Protocol; end

    MAPPINGS = {
      :StatusEvent => :Tweet
    }

    def self.type(source_data)
      type_name = extract_type_name(source_data).andand.camel_case.andand.gsub('Event','').andand.to_sym
      if MAPPINGS.include?(type_name) && self.constants.include?(MAPPINGS[type_name])
        self.const_get(MAPPINGS[type_name])
      elsif self.constants.include?(type_name)
        self.const_get(type_name)
      else
        fail MappingError.new("Couldn't find valid type for Twitter", type_name)
      end
    end

    def self.extract_type_name(source_data)
      if is_follow_event?(source_data)
        'Follow'
      elsif is_status_event?(source_data)
        'Tweet'
      elsif source_data[:custom_follow]
        'CustomFollow'
      end
    end

    def self.is_follow_event?(source_data)
      ((source_data['event'].andand == 'follow') &&
        source_data['source'] && source_data['target'])
    end

    def self.is_status_event?(source_data)
      (source_data['text'] &&
        source_data['user'].andand['screen_name'])
    end

    class Processor
      attr_reader :parsed, :extracted
      class Configuration; end

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
        @config.is_user_stream
      end
      
      def public_stream?
        not(user_stream?)
      end
    end

  end
end

require_relative 'types/tweet'
require_relative 'types/follow'
require_relative 'types/custom_follow'
