require 'koala'
require_relative '../protocol'

module Fetchers
  module Facebook
    class Base
      include Protocol

      LIMIT  = 250
      FIELDS = 'attachments,from,message,picture,link,object_id,updated_time,type,status_type'

      def initialize(client)
        @client = client
      end

      def self.fetch(client, *args)
        self.new(client).fetch(*args)
      end

    end
  end
end
