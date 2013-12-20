module Entities
  module Github
    module Issue

      class Builder
        def extract_attrs(payload)


        end
      end
      
      class Determinator
        def determine_tags
        end

        def determine_category
        end
      end

      class Grouper
        def find_parent
        end

        def find_children
        end

        def find_references
        end
      end

      # def find_issues_by_issue_id(issue_id)
      #   query = {
      #     tags: %w(github issues_event),
      #     props: { issue_id: issue_id }
      #   }
      # end

      # def find_issues_by_repo_name_and_issue_number(repo_name, issue_number)
      #   query = {
      #     tags: %w(github issues_event),
      #     props: {
      #       repo_name: repo_name
      #       issue_number: issue_number
      #     }
      #   }
      # end

    end
  end
end
