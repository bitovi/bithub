module Entities
  module Meetup
    class Event < Protocol; end
    class Rsvp < Protocol; end
  end
end

require_relative 'types/event'
require_relative 'types/rsvp'
