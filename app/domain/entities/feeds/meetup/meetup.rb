module Entities
  module Meetup
    class Event < Protocol; end
    class Rsvp < Protocol; end

    def self.type(arg)
      
      if arg.is_a? String
        type_name = arg
      elsif arg.is_a? Events::Protocol
        payload = arg
        type_name = arg.type_name
      end

      if MAPPINGS.include?(type_name)
        self.const_get(MAPPINGS[type_name])
      else
        self.constants.include?(type_name.to_sym) ? self.const_get(type_name) : nil
      end
    end

  end
end

require_relative 'types/event'
require_relative 'types/rsvp'
