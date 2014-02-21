module Events
  module StackExchange

    class Question < Protocol

      def content_digest
        Digest::MD5.hexdigest(self.class.name)
      end

    end

  end
end
