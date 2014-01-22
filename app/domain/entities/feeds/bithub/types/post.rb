module Entities
  module Bithub

    class Post < Entity
      attr_reader :instance

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        if @payload.wat && (entity = find_by_wat.first)
          @instance ||= entity
        else
          @instance ||= build
        end
        self
      end

      # Finders
      def find_by_wat?
        Entity.where(wat: @payload.wat)
      end

      def relationships
        Entities::Bithub::Post::Relationships
      end

    end

  end
end
