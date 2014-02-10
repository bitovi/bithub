module Entities
  module Twitter

    class Follow < Protocol

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def find
        nil
      end

      def build
        Rails.logger.info "KURCA BUILDAM TWITTER"
        Entity.new({
          title: "followed @#{@payload.target_screen_name}",
          origin_ts: @payload.origin_ts,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            target: @payload.target_screen_name,
          }
        })
      end
      
      def relationships
        Entities::Twitter::Follow::Relationships
      end

    end
  end
end
