module Entities
  module Meetup
    class Event; end

    def self.type(type_name)
      Entities::Meetup::Event
    end

  end
end

require 'entities/feeds/meetup/types/event'
