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
        self.const_get(type_name)
      end
    end

    def self.extract_type_name(source_data)
      if is_follow_event?(source_data)
        'Follow'
      elsif is_status_event?(source_data)
        'Tweet'
      elsif source_data['friends']
        fail Events::MappingError, "skipping Twitter 'friends' event"
      else
        fail Events::MappingError, "unknown Twitter event type"
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
      include Configurable

      attr_reader :parsed, :extracted

      def initialize(response, &blk)
        initialize_config
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
