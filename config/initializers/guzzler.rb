require 'guzzler/client'

# We always want to start from as clean a slate as possible, and since
# redis primarily serves as the cache, we need to clear all keys
Guzzler.redis do |conn|
	conn.flushdb
end

# We don't want to try and start the services when we are migrating
if ActiveRecord::Base.connection.table_exists? "services"
	# Since we are starting from a clear slate, we need to ensure 
	# that our polling and listening services are started.
	Service.all_services("polling").map do |service|
		service.guzzle_service
	end
	Service.all_services("listening").map do |service|
		service.guzzle_service
	end
end