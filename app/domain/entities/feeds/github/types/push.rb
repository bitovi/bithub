module Entities
  module Github

    class Push < Protocol
      include Entities::Github::Referencable

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::Commit],
        references: [Entities::Github::Issue, Entities::Github::PullRequest],
      }

      def find
        @payload.push_id && find_by_push_id.where(:parent_id => nil).first
      end

      def build
        built = Entity.new({
          title: "pushed to #{@payload.repo_name}",
          url: "https://github.com/#{@payload.repo_name}/commit/#{@payload.head}",
          origin_ts: @payload.origin_ts,
          origin_id: @payload.push_id.to_s,
          props: {
            origin_author_id: @payload.actor_id,
            origin_author_name: @payload.actor_login,
            origin_author_avatar_url: @payload.actor_avatar_url,
            repo_name: @payload.repo_name,
            commit_shas: @payload.commit_shas,
          }
        })

        built.props[:references_to] = @payload.referenced_issue_numbers_csv unless @payload.referenced_issue_numbers_csv.blank?

        built 
      end

      def build_children
        @payload.commit_shas.map do |sha|
          Entities::Github::Commit.new(@payload, sha)
            .procure
            .determine
            .group
            .normalize
            .instance
        end
      end
      
      # Finders
      
      def find_by_push_id
        Entity
        .feed('github')
        .type('push')
        .where(origin_id: @payload.push_id.to_s)
      end

      def find_by_commit_id
        Entity
        .feed('github')
        .type('push')
        .where("props -> 'commit_shas' LIKE '%#{@payload.commit_id}%'")
      end

    end

  end
end
