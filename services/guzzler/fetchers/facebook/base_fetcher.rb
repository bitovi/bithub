require 'koala'
require 'guzzler/fetchers/protocol'

module Guzzler::Fetchers

  module Facebook
    class BaseFetcher
      include Protocol

      LIMIT  = 99
      FIELDS = 'attachments,from,message,picture,link,object_id,updated_time,type,status_type'

      def initialize(service = nil)
        @service = (block_given?) ? yield : service
      end
        
      def client
        Koala::Facebook::API.new(@service.config.fetch(:access_token))
      end
    end
  end
end
