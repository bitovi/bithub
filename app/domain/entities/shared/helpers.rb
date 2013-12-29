module Entities
	module Helpers
		def feed_type_names(event)
			_, feed, type = event.class.to_s.match(/.*::(.*)::(.*)/).to_a
      [feed, type]
		end
	end
end
