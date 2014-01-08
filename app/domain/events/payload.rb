module Events
  class Payload
    class MissingFeedError < Exception; end
    class MissingTypeError < Exception; end

    def initialize(payload)
    end

    def initialize(payload)
      @data = symbolize_keys(payload)
      verify_existance_of_critical_attributes
      initialize_mappings
      remap_feed_and_type
      @event = construct_event(@data)
    end

    def method_missing(method, *args, &block)
      @event.send(method, *args, &block)
    end
    
    def switch_to_camel_case
      Payload.switch_to_camel_case(@data)
      self
    end

    def switch_to_snake_case
      Payload.switch_to_snake_case(@data)
      self
    end

    def construct_event(payload)
      feed = payload.andand[:meta].andand[:feed].capitalize
      type = payload.andand[:meta].andand[:type].capitalize
      fail MissingFeedError if !feed
      fail MissingTypeError if !type
      Events.const_get(feed).const_get(type).new(payload)
    end


    def remap_feed_and_type
      @data[:meta][:feed] = @feed_mappings[@data[:meta][:feed]]
      @data[:meta][:type] = @type_mappings[@data[:meta][:type]]
    end

    def ==(other)
      @data == other
    end

    def raw
      @data
    end

    def self.switch_to_snake_case(hash)
      if hash[:meta]
        hash[:meta][:feed] = hash[:meta][:feed].snake_case
        hash[:meta][:type] = hash[:meta][:type].snake_case
      else 
        hash[:feed] = hash[:feed].snake_case
        hash[:type] = hash[:type].snake_case
      end
    end

    def self.switch_to_camel_case(hash)
      if hash[:meta]
        hash[:meta][:feed] = hash[:meta][:feed].camel_case
        hash[:meta][:type] = hash[:meta][:type].camel_case
      else 
        hash[:feed] = hash[:feed].camel_case
        hash[:type] = hash[:type].camel_case
      end
    end

    private
    def verify_existance_of_critical_attributes
      puts @data.inspect
      fail MissingFeedError unless @data[:meta][:feed]
      fail MissingTypeError unless @data[:meta][:type]
    end

    def initialize_mappings
      @feed_mappings = Hash.new(@data[:meta][:feed])
      @feed_mappings[:forums] = 'forum'

      @type_mappings = Hash.new(@data[:meta][:type])
      @type_mappings[:status_event] = 'tweet'
      @type_mappings[:issues_event] = 'issue_event'
    end

    def symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end



  end
end


require 'andand'
require 'core_ext'

module Events
  class Payload
  end

end
