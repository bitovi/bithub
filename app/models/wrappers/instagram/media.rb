require 'wrappers/data_accessible'

module Wrappers
  module Instagram

    class Media
      include DataAccessible
      include CoreHelpers

      has :id, :type, :link, :created_time, :filter, :tags, \
          :location, :comments, :likes, :images, :users_in_photo, \
          :caption, :user

      def initialize(media)
        @data = symbolize_keys(media)
        @user = Wrappers::Instagram::User.new(@data.andand[:user])
      end

    end
  end
end
