module Entities
	module Facebook
		class Like < Protocol; end
		class Comment < Protocol; end
		class Status < Protocol; end
	end
end

require_relative 'types/like'
require_relative 'types/comment'
require_relative 'types/status'
