module Entities
  module Github

    class Watch < Protocol
      include Events::Github::Accessors::Standard

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }
      
      def find
        @payload.origin_id && find_by_actor_and_repo_name.first
      end

      def build
        Entity.new({
          title: "started watching #{@payload.repo_name}",
          origin_ts: @payload.origin_ts,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            repo_name: @payload.repo_name,
          }
        })
      end

      def find_by_origin_id
        Entity.tagged_with(%w(github watch))
        .where("props -> 'origin_id' = '#{@payload.origin_id}'")
      end

      def find_by_actor_and_repo_name
        Entity.tagged_with(%w(github watch))
        .where("props -> 'origin_author_id' = '#{@payload.origin_author_id}'")
        .where("props -> 'repo_name' = '#{@payload.repo_name}'")
      end


      def relationships
        Entities::Github::Watch::Relationships
      end
    end

  end
end
