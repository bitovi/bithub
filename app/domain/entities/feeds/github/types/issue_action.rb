module Entities
  module Github

    class IssueAction < Protocol

      Relationships = {
        upstream: [Entities::Github::Issue],
        downstream: [],
        references: [],
      }

      def find
        nil
      end
      
      def find_parent
        if @payload.repo_name && @payload.number
          matches = relationships[:upstream].reduce([]) do |acc, rl|
            acc << rl.new(@payload).find_by_repo_name_and_number.first
          end
          parent = matches.compact.first
        end
      end

      # Builder
      def build
        built = Entity.new({
          title: "#{@payload.nice_name} ##{@payload.number} #{@payload.action}",
          origin_ts: @payload.origin_ts,
          origin_id: @payload.origin_id.to_s,
          props: {
            origin_author_id: @payload.actor_id,
            origin_author_name: @payload.actor_login,
            origin_author_avatar_url: @payload.actor_avatar_url,
            repo_name: @payload.repo_name,
            number: @payload.number,
            state: @payload.state,
            action: @payload.action,
          }
        })
        if @payload.respond_to? :label_names
          built.props[:label_names] = @payload.label_names
        end
        built
      end

      def update_parent
        @instance.parent.title = @payload.title
        @instance.parent.body = @payload.body
        @instance.parent.props[:state] = @payload.state
        if @payload.respond_to? :label_names
          @instance.parent.props[:label_names] = @payload.label_names
        end
      end

      # Finders
      def find_by_origin_id
        scope = Entity.feed('github')
        .type(my_type_tag)
        .where(origin_id: @payload.origin_id.to_s)
      end

      def find_by_repo_name_and_number
        Entity
        .feed('github')
        .type(my_type_tag)
        .where("props -> 'repo_name' = '#{@payload.repo_name}'")
        .where("props -> 'number' = '#{@payload.number}'")

      end

      def my_type_tag
        if self.class.name =~ /Issue/
          'issue_action'
        end
      end

      def relationships
        Entities::Github::IssueAction::Relationships
      end
      
    end

    PullRequestAction = IssueAction
  end
end
