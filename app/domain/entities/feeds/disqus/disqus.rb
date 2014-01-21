module Entities
  module Disqus
    class Post; end

    def self.type(arg)
      Entities::Blog::Post
    end
  end
end

require 'entities/feeds/disqus/types/post'
