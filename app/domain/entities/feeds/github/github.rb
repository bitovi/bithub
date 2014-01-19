module Entities
  module Github
    MAPPINGS = {
      'CustomIssue' => 'Issue',
      'CustomWatch' => 'Watch',
    }

    def self.type(payload)
      if MAPPINGS.include?(payload.type)
        self.const_get(MAPPINGS[payload.type])
      else
        self.const_get(payload.type)
      end
    end
        
    class Commit; end
    class CommitComment; end
    class Issue; end
    class IssueAction; end
    class IssueComment; end
    class PullRequest; end
    class Pull; end
    class Push; end
    class Watch; end
  end
end

require 'entities/feeds/github/types/commit'
require 'entities/feeds/github/types/commit_comment'
require 'entities/feeds/github/types/issue'
require 'entities/feeds/github/types/issue_pull_request_action'
require 'entities/feeds/github/types/issue_comment'
require 'entities/feeds/github/types/pull_request'
require 'entities/feeds/github/types/push'
require 'entities/feeds/github/types/watch'
