module Entities
  module Github

    def self.mapper(payload)
      self.const_get(payload.type.camel_case.gsub(/Event/,''))
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
