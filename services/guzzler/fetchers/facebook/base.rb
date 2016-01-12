require 'koala'

require 'guzzler/fetchers/protocol'

module Guzzler
  module Fetchers

    module Facebook
      class Base
        include Protocol

        LIMIT  = 250
        FIELDS = 'attachments,from,message,picture,link,object_id,updated_time,type,status_type'

        def initialize(client, opts={})
          @client    = client
          @object_id = opts[:object_id]
        end

      end
    end
  end
end
