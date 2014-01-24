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
          thread_updated_ts: @payload.origin_ts,
          props: {
            repo_name: @payload.repo_name,
            commit_shas: @payload.commit_shas,
            push_id: @payload.push_id,
          }
        })
      end

      def build_children
        @payload.commit_shas.map do |sha|
          commit = Entities::Github::Commit.new(@payload, sha).procure
          commit.determine
          commit.build_references
          commit
        end
      end
      
      def find_references
        if @payload.repo_name && @payload.referenced_issue_number
          relationships[:references].reduce([]) do |acc, rl|
            acc += rl.find_by_repo_name_and_number(
              @payload.referenced_repo_name,
              @payload.referenced_number
            ).all
          end
        end
      end

      # override Referencable
      def search_for_references_in_content
        @payload.commit_messages
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
