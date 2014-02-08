module Entities
  module Github
    module Referencable

      def find_references_from_self
        Entity
        .type('github')
        .where("props -> 'repo_name' = '#{@payload.repo_name}'")
        .where("props -> 'number' = ANY(#{references_in_content.to_postgres_array})")
        .all
      end
      
      def find_references_to_self
        if nice_name =~ /Issue/ || nice_name =~ /PullRequest/
          Entity
          .type('github')
          .where("props -> 'repo_name' = '#{@payload.repo_name}'")
          .where("'#{@payload.number}' = ANY(string_to_array(props -> 'references_to', ','))")
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
