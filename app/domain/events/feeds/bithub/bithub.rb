module Events
  module Bithub
    module Postlike; end
    class Post < Protocol; end
    class Event < Protocol; end

    def self.type(source_data)
      if source_data[:scheduled_at]
        type = Events::Bithub::Event
      else
        type = Events::Bithub::Post
      end
      type
    end

  end
end


require_relative 'traits/postlike'
require_relative 'types/post'
require_relative 'types/event'