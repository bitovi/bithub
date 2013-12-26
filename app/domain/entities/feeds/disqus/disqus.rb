require 'entities/feeds/disqus/types/post'
require 'entities/feeds/disqus/types/thread'

module Entities
	module Disqus

		class Procurer
			def initialize(persistor)
				@p = persistor
			end

			def find_or_build(event)
				Entities::Disqus::Post::Procurer.new(@p).find_or_build(event)
			end
		end

	end
end
