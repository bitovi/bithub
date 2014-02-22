module Wrappers
  module Meetup

    class Member
      include CoreHelpers

      def initialize(member, member_photo)
        @m = symbolize_keys(member)
        @mp = symbolize_keys(member_photo)
      end

      def raw
        @m
      end

      def id
        @m.andand[:member_id]
      end

      def name
        @m.andand[:name]
      end

      def thumb_link
        @mp.andand[:thump_link]
      end

    end
  end
end
