module Configurable
	def initialize_config(&blk)
    @config = Configuration.new
    blk.(@config) if blk
	end
end
