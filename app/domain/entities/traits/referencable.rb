module Entities
  module Github
    module Referencable

      def build_references
        Entity
          .tagged_with(['github'])
          .tagged_with(['issue', 'pull_request'], :any => true)
          .where("props -> 'number' = ANY(#{search_for_references_in_content.to_postgres_array})")
          .where("props -> 'repo_name' = '#{@payload.repo_name}'")
          .each {|e| @instance.referencing.push e}
      end

      def search_for_references_in_content
        @payload.references
      end

      def persist!
        build_references
        super
      end
      
    end    
  end
end
