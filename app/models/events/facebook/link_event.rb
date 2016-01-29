require 'events/protocol'

module Events
  module Facebook

    class LinkEvent < Protocol
      extend Forwardable

      def_delegators :@link_obj, :id, :type, :link, :message, :picture, :description, :images, :created_time, :updated_time

      attr_accessor :link_obj, :from, :comments, :likes

      def digest_seed
        id + self.class.name
      end

      def wrap_response
        @link_obj     ||= Wrappers::Facebook::Link.new source_data
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
