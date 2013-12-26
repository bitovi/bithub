module Entities
	module Forum
		class Procurer

			def initialize(persistor)
				@p = persistor
			end

			def find_or_build(event)
				Entities::Forum::Post::Procurer.new(@p).find_or_build(event)
			end

		end
	end
end
