module Entities
  module Bithub

    class Post
      include Entities::Constructable
      include Entities::Determinable
      
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

      def procure_parent
      end

      def procure_children
      end

      def procure_references
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
