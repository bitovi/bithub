module Entities
	module Forum
		class Post < Protocol; end

    def self.type(arg)
      Entities::Forum::Post
    end

	end
end

require_relative 'types/post'
