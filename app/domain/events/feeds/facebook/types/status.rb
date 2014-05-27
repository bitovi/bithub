module Events
  module Facebook

    class Status < Protocol
      extend Forwardable

      def_delegators :@status, :id, :type, :link, :message, :created_time, :updated_time

      attr_accessor :status, :poster, :comments

      def digest_seed
        id + self.class.name
      end

      def wrap_response
        @status ||= Wrappers::Facebook::Status.new(source_data)
        @poster ||= Wrappers::Facebook::Poster.new(source_data.fetch(:from))
        @comments ||= source_data[:comments].andand[:data].andand.map do |c|
          Wrappers::Facebook::Comment.new(c)
        end
        self
      end
    end

  end
end
