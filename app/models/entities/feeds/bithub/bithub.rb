module Entities
  module Bithub
    class Post < Protocol; end
    class Event < Post; end
  end
end

require_relative 'types/event'
require_relative 'types/post'
