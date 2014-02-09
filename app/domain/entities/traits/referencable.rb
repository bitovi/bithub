module Entities
  module Github
    module Referencable

      def find_references_from_self
        if references_in_content
          Entity
          .feed('github')
          .repo_name(@payload.repo_name)
          .where("string_to_array(props -> 'number', ',') @> string_to_array('#{references_in_content_csv}', ',')")
          .all
        end
      end

      def find_references_to_self
        if @payload.respond_to? :number
          Entity
          .feed('github')
          .repo_name(@payload.repo_name)
          .where("string_to_array('#{@payload.number}', ',') @> string_to_array(props -> 'references_to', ',')")
          .all
        end
      end

      def referenced_repo_name
        @payload.referenced_repo_name || @payload.repo_name
      end

      def references_in_content
        @payload.referenced_issue_numbers
      end

      def references_in_content_csv
        references_in_content.join(',')
      end

    end    
  end
end
