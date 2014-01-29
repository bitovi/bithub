module Entities
  module Github

    class Push < Protocol
      include Entities::Github::Referencable

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::CommitComment, Entities::Github::Commit],
        references: [Entities::Github::Issue, Entities::Github::PullRequest],
      }

      def find
        @payload.push_id && find_by_push_id.where(:parent_id => nil).first
      end

      def build
        Entity.new({
          title: "pushed to #{@payload.repo_name}",
          url: "https://github.com/#{@payload.repo_name}/commit/#{@payload.head}",
          origin_ts: @payload.origin_ts,
          props: {
            repo_name: @payload.repo_name,
            commit_shas: @payload.commit_shas,
            origin_id: @payload.push_id,
          }
        })
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
      
      # override Referencable
      def references_in_content
        @payload.referenced_issue_numbers
      end

      # Finders
      
      def find_by_push_id
        Entity.tagged_with(['github', 'push'])
        .where("props -> 'origin_id' = '#{@payload.push_id}'")
      end

      def find_by_commit_id
        Entity.tagged_with(['github', 'push'])
        .where("props -> 'commit_shas' LIKE '%#{@payload.commit_id}%'")
      end

    end

  end
end
