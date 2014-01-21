module Entities
  module Github

    class CommitComment
      include Entities::Constructable
      include Entities::Determinable

      attr_reader :instance

      Relationships = {
        upstream: [Entities::Github::Push],
        downstream: [],
        references: [],
      }

      def procure
        @instance = (@payload.commit_id && (e = find_by_commit_id.first)) ? e : build
        self
      end

      def procure_parent
        if @payload.commit_id
          Entities::Github::Push::Procurer
          .new(@payload)
          .find_by_commit_id
          .first
        end
      end

      def procure_children
      end

      def procure_references
      end

      # Builder
      def build
        e = Entity.new({
          title: "commented on a commit in #{@payload.repo_name}",
          body: @payload.body,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            feed: @payload.feed,
            type: @payload.type,
            repo_name: @payload.repo_name,
            commit_id: @payload.commit_id,
          }
        })
        e.props.symbolize_keys!
        e
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
