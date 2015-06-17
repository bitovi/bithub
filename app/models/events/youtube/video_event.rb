require 'events/protocol'

module Events
  module Youtube

    class VideoEvent < Protocol
      extend Forwardable

      def_delegators :@video, :id, :title, :description, :created_time, :channel_title, :channel_id, :thumbnail

      attr_accessor :video

      def digest_seed
        id + self.class.name
      end

      def wrap_response
        @video ||= Wrappers::Youtube::Video.new source_data
        self
      end
    end

  end
end
