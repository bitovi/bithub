module Entities
  module Github
    MAPPINGS = {
      'CustomIssue' => 'Issue',
      'CustomWatch' => 'Watch',
    }

    def self.type(arg)
      if arg.is_a? String
        type_name = arg
      elsif arg.is_a? Events::Protocol
        payload = arg
        type_name = arg.type_name
      end

      if MAPPINGS.include?(type_name)
        self.const_get(MAPPINGS[type_name])
      elsif issue_action?(payload)
        Entities::Github::IssueAction
      else
        self.const_get(type_name) if self.constants.include? type_name.to_sym
      end
    end

    def self.issue_action?(payload)
      (payload.class.name =~ /Issue/ || payload.class.name =~ /PullRequest/) && not(payload.class.name =~ /IssueComment/)
      payload.respond_to?(:state) && payload.respond_to?(:action) && payload.action != 'opened'
    end

    class Commit < Protocol; end
    class CommitComment < Protocol; end
    class Issue < Protocol; end
    class IssueAction < Protocol; end
    class IssueComment < Protocol; end
    class PullRequest < Protocol; end
    class Pull < Protocol; end
    class Push < Protocol; end
    class Watch < Protocol; end
  end
end

require_relative 'types/commit'
require_relative 'types/commit_comment'
require_relative 'types/issue'
require_relative 'types/issue_action'
require_relative 'types/issue_comment'
require_relative 'types/pull_request'
require_relative 'types/push'
require_relative 'types/watch'
require_relative 'types/fork'
require_relative 'types/public'
require_relative 'types/create'
