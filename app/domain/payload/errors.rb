module Payload
	module Errors
		class MissingTimestamp < Exception; end
		class InvalidEventException < Exception; end
		class UnknownFeedException < Exception; end
		class UnknownTypeException < Exception; end
	end
end
