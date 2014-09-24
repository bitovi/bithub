module Fetchers
  module Instagram

    class Media < Base

      def fetch(media_id)
        @result = @client.media_item media_id
      end

      def self.fetch(media_id)
        self.new.fetch media_id
      end

    end

  end
end
