module Entities
  module Github


    module IssueAttributeFinder
      def find(payload)
        if payload.issue_id
          find_by_issue_id(payload.issue_id).all
        elsif payload.repo_name && payload.issue_number
          find_by_repo_name_and_issue_number(payload.repo_name, payload.issue_number).all
        end
      end
    end

    module Commit; end
    module CommitComment; end
    module Issue; end
    module IssueAction; end
    module IssueComment; end
    module PullRequest; end
    module Pull; end
    module Push; end
    module Watch; end
  end
end

require 'entities/feeds/github/types/commit'
require 'entities/feeds/github/types/commit_comment'
require 'entities/feeds/github/types/issue'
require 'entities/feeds/github/types/issue_action'
require 'entities/feeds/github/types/issue_comment'
require 'entities/feeds/github/types/pull_request'
require 'entities/feeds/github/types/push'
require 'entities/feeds/github/types/watch'
