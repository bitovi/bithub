module Entities
  module Github
    module Push

      class Procurer < Github::Procurer
      end

      module Finders
        def find_pushes_by_repo_name_and_referenced_issue_number(repo_name, referenced_issue_number)
          .tagged_with(['github', 'push_event'])
          .name_and_number(repo_name, referenced_issue_number)
        end

        def find_pushes_by_commit_sha(commit_sha)
          .tagged_with(['github','push_event'])
          .where("props -> 'commit_shas' LIKE '%#{commit_sha}%'")
        end
      end

    end
  end
end
