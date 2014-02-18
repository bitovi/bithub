module Entities
  module Github
    class Commit < Protocol; end
    class Issue < Protocol; end
    class IssueAction < Protocol; end
    class IssueComment < Protocol; end
    class PullRequest < Protocol; end
    class Push < Protocol; end
    class Watch < Protocol; end
  end
end

require_relative 'types/commit'
require_relative 'types/create'
require_relative 'types/fork'
require_relative 'types/issue'
require_relative 'types/issue_action'
require_relative 'types/issue_comment'
require_relative 'types/public'
require_relative 'types/pull_request'
require_relative 'types/push'
require_relative 'types/watch'
