module Entities
  module Blog
    class Post; end

    def self.type(arg)
      Entities::Blog::Post
    end
  end
end

require 'entities/feeds/blog/types/post'
