module Events
  module Facebook

    class Status < Protocol
      extend Forwardable

      def_delegators :@status, :id, :type, :link

      attr_accessor :user

      def digest_seed
        id + self.class.name
      end

      def wrap_response
        @status ||= Wrappers::Facebook::Status.new(source_data)
        self
      end
    end

  end
end
