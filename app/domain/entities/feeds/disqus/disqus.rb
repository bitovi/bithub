module Entities
  module Disqus
    class Post < Protocol; end

    def self.type(arg)
      Entities::Blog::Post
    end
  end
end

require_relative 'types/post'
