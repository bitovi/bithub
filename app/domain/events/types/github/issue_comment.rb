module Events
  module Github
    class IssueComment

      def entity_exists?
        Entities::Github::Issue.find_issues_by_issue_id(issue_id_from_payload(source_data))
      end

      def create_or_update
        if entity_exists?
          update_entity(extract_for_update(payload))
        else
          create_entity(extract_for_create(payload))
        end
      end

      def entities_to_create
        entities_that_should_exist_but_dont #KAKO?
      end

      def entities_to_update
        entities_to_check.map{|e| e.is_dirty?}
      end

      def touches
        [Entities::Github::IssueComment, Entities::Github::Issue, Entities::Github::PullRequest, Entities::Github::Push]
      end
      
      def entities_to_check
        touches.map do |entity_model|
          entity_model.find_all_by_issue_comment
        end.flatten
      end

    end
  end
end
