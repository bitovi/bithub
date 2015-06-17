require 'events/protocol'

module Events
  module Instagram

    class MediaEvent < Protocol
      extend Forwardable

      def_delegators :@media, :id, :type, :link, :created_time
      attr_reader :user


      def digest_seed
        id + self.class.name
      end

      def created_at
        Time.at @media.created_time.to_i
      end

      def wrap_response
        @media ||= Wrappers::Instagram::Media.new source_data
        @user  ||= Wrappers::Instagram::User.new source_data[:user]
        self
      end
    end

  end
end
