module Entities
  module Meetup
    class Event < Protocol; end
    class Rsvp < Protocol; end

    def self.type(arg)
      if arg.is_a? String
        type_name = arg.capitalize.to_sym
      elsif arg.is_a? Events::Protocol
        payload = arg
        type_name = arg.type_name.capitalize.to_sym
      end

      if self.constants.include?(type_name)
        self.const_get(type_name)
      else
        fail MappingError.new("Couldn't find valid type for Meetup", type_name)
      end
    end

  end
end

require_relative 'types/event'
require_relative 'types/rsvp'
