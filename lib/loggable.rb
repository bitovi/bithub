module Loggable
	def initialize_logger
		@logger = Log4r::Logger.new(self.class.to_s)
		@logger.add(Log4r::StdoutOutputter.new('console', {
			:formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
		}))
	end
end
