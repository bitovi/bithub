module Events
  module Foursquare

    class Checkin < Protocol

      def digest_seed
        id + self.class.name
      end

      def user
        @user
      end

      def venue
        @venue
      end

      def id
        source_data.fetch(:id)
      end

      def type
        source_data.fetch(:type)
      end

      def created_at
        Time.at source_data.fetch(:createdAt)
      end

      def wrap_response
        @user ||= Wrappers::Foursquare::User.new source_data.fetch(:user)
        @venue ||= Wrappers::Foursquare::Venue.new source_data.fetch(:venue)
        self
      end
    end

  end
end
