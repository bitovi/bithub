module Configurable
	def initialize_config(&blk)
    @config = OpenStruct.new
    blk.(@config) if blk
	end
end
