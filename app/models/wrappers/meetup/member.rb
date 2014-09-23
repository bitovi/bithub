require 'wrappers/data_accessible'

module Wrappers
  module Meetup

    class Member
      include CoreHelpers

      def initialize(member, member_photo = nil)
        @data = symbolize_keys(member)
        @mp = symbolize_keys(member_photo)
      end

      def id
        @data.fetch(:member_id) do
          @data.fetch(:id)
        end
      end

      def name
        @data.fetch(:member_name) do
          @data.fetch(:name)
        end
      end

      def thumb_link
        @mp.andand[:thumb_link]
      end

    end
  end
end
