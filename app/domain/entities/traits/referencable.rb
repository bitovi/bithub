module Entities
  module Github
    module Referencable

      def find_references
        Entity
          .tagged_with(['github'])
          .tagged_with(['issue', 'pull_request'], :any => true)
          .where("props -> 'number' = ANY(#{references_in_content.to_postgres_array})")
          .where("props -> 'repo_name' = '#{@payload.repo_name}'")
          .all
      end

      def references_in_content
        @payload.referenced_issue_numbers
      end
      
    end    
  end
end
