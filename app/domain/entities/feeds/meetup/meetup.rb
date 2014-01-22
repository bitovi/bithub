module Entities
  module Meetup
    class Event < Protocol; end

    def self.type(type_name)
      Entities::Meetup::Event
    end

  end
end

require_relative 'types/event'
