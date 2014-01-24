module Entities
  module Github

    class CommitComment < Protocol
      include Entities::Github::Referencable

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [],
        references: [],
      }

      def find
        @payload.commit_id && find_by_commit_id.first
      end

      def build
        Entity.new({
          title: "commented on a commit in #{@payload.repo_name}",
          body: @payload.body,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            repo_name: @payload.repo_name,
            commit_id: @payload.commit_id,
          }
        })
      end

      def find_children
        if @payload.commit_id
          Entities::Github::Push
          .new(@payload)
          .find_by_commit_id
          .first
        end
      end

      # Finders
      def find_by_commit_id
        Entity.tagged_with(['github', 'commit_comment'])
        .where("props -> 'commit_id' = '#{@payload.commit_id}'")
      end

      def find_by_multiple_commit_shas
        Entity.tagged_with(['github', 'commit_comment'])
        .where("position(props -> 'commit_id' in '#{@payload.commit_shas_csv}') > 0")
      end
    end

  end
end
