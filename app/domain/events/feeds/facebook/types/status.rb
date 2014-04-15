module Events
  module Facebook

    class Status < Protocol
      extend Forwardable

      def_delegators :@status, :id, :type, :link, :message, :created_time, :updated_time

      attr_accessor :status, :poster

      def digest_seed
        id + self.class.name
      end

      def wrap_response
        @status ||= Wrappers::Facebook::Status.new(source_data)
        @poster ||= Wrappers::Facebook::Poster.new(source_data.fetch(:from))
        self
      end
    end

  end
end
