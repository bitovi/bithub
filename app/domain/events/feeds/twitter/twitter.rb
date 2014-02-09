require_relative 'types/tweet'
require_relative 'types/follow'

module Events
  module Twitter
    class Tweet < Protocol; end
    class Follow < Protocol; end

    MAPPINGS = {
      'StatusEvent' => 'Tweet'
    }

    def self.type(source_data)
      type_name = extract_type_name(source_data).camel_case.gsub('Event','')
      if MAPPINGS && MAPPINGS.include?(type_name)
        self.const_get(MAPPINGS[type_name])
      else
        self.constants.include?(type_name.to_sym) ? self.const_get(type_name) : nil
      end
    end

    def self.extract_type_name(source_data)
      if is_follow_event?(source_data)
        'Follow'
      elsif is_status_event?(source_data)
        'Tweet'
      else
        'NonExistingType'
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
