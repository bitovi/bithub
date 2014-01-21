module Entities
  module Meetup

    class Event
      include Entities::Constructable
      include Entities::Determinable

      def procure
        @instace = (@payload && (e = sclass.find_by_id.first)) ? e : build
        self
      end

      def build
        e = Entity.new({
          title: 'some events',
          body: 'dksajflaskdjfalskdfj',
          url: 'http://www.google.com',
        })
        e.props.symbolize_keys!
        e
      end

      def self.find_by_id
        Entity.where(:title => 'skdjfslkdj')
      end

    end

  end
end
