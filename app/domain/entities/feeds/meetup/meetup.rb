module Entities
  module Meetup
    class Event < Protocol; end
    class Rsvp < Protocol; end

    def self.type(type_name)
      if MAPPINGS.include?(type_name)
        self.const_get(MAPPINGS[type_name])
      else
        self.const_get(type_name)
      end
    end

  end
end

require_relative 'types/event'
require_relative 'types/rsvp'
