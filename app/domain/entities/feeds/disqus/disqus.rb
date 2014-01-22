module Entities
  module Disqus
    class Post < Protocol; end

    def self.type(arg)
      Entities::Disqus::Post
    end
  end
end

require_relative 'types/post'
