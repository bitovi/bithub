module Wrappers
  module Meetup

    class Member
      extend DataAccessible
      include CoreHelpers

      data_accessors :member_id, :name
      alias_method :id, :member_id

      def initialize(member, member_photo = nil)
        @data = symbolize_keys(member)
        @mp = symbolize_keys(member_photo)
      end

      def thumb_link
        @mp.andand[:thumb_link]
      end

    end
  end
end
