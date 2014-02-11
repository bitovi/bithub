module Events
  module Bithub
    module Postlike; end
    class Post < Protocol; end
    class Event < Post; end
  end
end

require_relative 'traits/postlike'
require_relative 'types/post'
require_relative 'types/event'
