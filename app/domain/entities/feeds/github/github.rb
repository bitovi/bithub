module Entities
  module Github
    MAPPINGS = {
      'CustomIssue' => 'Issue',
      'CustomWatch' => 'Watch',
    }

    def self.type(arg)
      if arg.is_a? String
        type_name = arg
      elsif arg.is_a? Payload
        type_name = arg.type
      end

      if MAPPINGS.include?(type_name)
        self.const_get(MAPPINGS[type_name])
      else
        self.const_get(type_name)
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
require 'entities/feeds/github/types/issue_action'
require 'entities/feeds/github/types/issue_comment'
require 'entities/feeds/github/types/pull_request'
require 'entities/feeds/github/types/push'
require 'entities/feeds/github/types/watch'
