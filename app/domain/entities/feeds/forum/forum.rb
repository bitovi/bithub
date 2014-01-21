module Entities
	module Forum
		class Post; end

    def self.type(arg)
      Entities::Forum::Post
    end

	end
end

require 'entities/feeds/forum/types/post'
