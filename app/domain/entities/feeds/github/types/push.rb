module Entities
  module Github

    class Push < Protocol

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::CommitComment, Entities::Github::Commit],
        references: [Entities::Github::Issue, Entities::Github::PullRequest],
      }
      
      def procure
        if @payload.push_id && (e = find_by_push_id.first)
          e.props.symbolize_keys!
          @instance = e
        else
          @instance = build
        end
        self
      end

      def procure_parent
      end

      def procure_children
        if @payload.commits
          commit_comments = Entities::Github::CommitComment
          .new(@payload)
          .find_by_multiple_commit_shas.all

          commits = Entities::Github::Commit
          .new(@payload)
          .procure

          entities = [] + commit_comments + commits
        end
      end

      def procure_references
        if @payload.repo_name && @payload.referenced_issue_number
          relationships[:references].reduce([]) do |acc, rl|
            acc += rl.find_by_repo_name_and_number(
              @payload.referenced_repo_name,
              @payload.referenced_number
            ).all
          end
        end
      end

      # Builder
      def build
        e = Entity.new({
          title: "pushed to #{@payload.repo_name}",
          url: "https://github.com/#{@payload.repo_name}/commit/#{@payload.head}",
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            feed: @payload.feed,
            type: @payload.type,
            repo_name: @payload.repo_name,
            commit_shas: @payload.commit_shas,
            push_id: @payload.push_id,
          }
        })
      end

      def build_children
        @payload.commit_shas.map do |sha|
          Entities::Github::Commit.new(@payload, sha).procure
        end
      end

      def create_children
        children = build_children
        children.each {|c| c.determine; c.persist!}        
        children
      end

      # Finders
      def find_by_push_id
        Entity.tagged_with(['github', 'push'])
        .where("props -> 'push_id' = '#{@payload.push_id}'")
      end

      def find_by_commit_id
        Entity.tagged_with(['github', 'push'])
        .where("props -> 'commit_shas' LIKE '%#{@payload.commit_id}%'")
      end
    end

  end
end
