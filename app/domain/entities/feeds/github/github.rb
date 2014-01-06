module Entities
  module Github
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
