module Entities
	module Facebook
		class Comment < Protocol; end
		class Status < Protocol; end
	end
end

require_relative 'types/status'
require_relative 'types/comment'
