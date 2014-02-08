module Entities
  module Github
    module Referencable

      def find_references_from_self
        Entity
          .type('github')
          .tagged_with(['issue', 'pull_request'], :any => true)
          .where("props -> 'number' = ANY(#{references_in_content.to_postgres_array})")
          .where("props -> 'repo_name' = '#{@payload.repo_name}'")
          .all
      end
      
      def find_references_to_self
        if nice_name =~ /Issue/ || nice_name =~ /PullRequest/
          Entity
          .type('github')
          .tagged_with(['issue', 'pull_request', 'issue_comment'], :any => true)
          .where("'#{@payload.number}' = ANY(string_to_array(entities.props -> 'references_to', ','))")
          .where("props -> 'repo_name' = '#{@payload.repo_name}'")
          .all
        else
          []
        end
      end

      def references_in_content
        @payload.referenced_issue_numbers
      end
      
    end    
  end
end
