module Entities
  module Twitter
    class TypeDeterminator < Entities::TypeDeterminator

      Mappings = {
        :TweetEvent => :Tweet,
        :FollowEvent => :Follow,
        :CustomFollowEvent => :Follow,
        :FakeFollowEvent => :Follow,
      }

      def initialize(event)
        super
        @mappings = Hash.new(@event.type_name).merge(Mappings)
      end

      def type_class
        super({ namespace: Twitter, type_name: remapped_type })
      end

      private
      def remapped_type
        @mappings[@event.type_name.to_sym]
      end
    end
  end
end
