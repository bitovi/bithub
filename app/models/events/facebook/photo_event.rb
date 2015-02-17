module Events
  module Facebook

    class PhotoEvent < Protocol
      extend Forwardable

      def_delegators :@photo, :id, :photo_id, :type, :picture, :source, :images, :link, :message, :created_time, :updated_time

      attr_accessor :photo, :from, :comments, :likes

      def digest_seed
        id + self.class.name
      end

      def wrap_response
        @photo    ||= Wrappers::Facebook::Photo.new source_data
        @from     ||= Wrappers::Facebook::From.new source_data.fetch :from
        @comments ||= source_data[:comments].andand[:data].andand.map do |c|
          Wrappers::Facebook::Comment.new c
        end
        @likes    ||= source_data[:likes].andand[:data].andand.map do |l|
          Wrappers::Facebook::Like.new l
        end

        self
      end
    end

  end
end
