module Wrappers
  module Meetup

    class Member
      extend DataAccessible
      include CoreHelpers

      data_accessors :member_id, :member_name

      alias_method :id, :member_id
      alias_method :name, :member_name

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
