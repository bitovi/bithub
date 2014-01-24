require_relative 'accessors'

module Events
  module Github
    class CommitComment < Protocol; end
    class Create < Protocol; end
    class CustomIssue < Protocol; end
    class Delete < Protocol; end
    class Download < Protocol; end
    class Follow < Protocol; end
    class Fork < Protocol; end
    class ForkApply < Protocol; end
    class Gist < Protocol; end
    class Gollum < Protocol; end
    class Issue < Protocol; end
    class IssueComment < Protocol; end
    class Member < Protocol; end
    class Public < Protocol; end
    class PullRequest < Protocol; end
    class PullRequestReviewComment < Protocol; end
    class PullRequestReviewComment < Protocol; end
    class Push < Protocol; end
    class TeamAdd < Protocol; end
    class Watch < Protocol; end

    MAPPINGS = {
      'Issues' => 'Issue',
    }

    def self.type(source_data)
      type_name = extract_type_name(source_data).camel_case.gsub(/Event/,'')
      if MAPPINGS && MAPPINGS.include?(type_name)
        self.const_get(MAPPINGS[type_name])
      else
        self.const_get(type_name)
      end
    end
      
    def self.extract_type_name(source_data)
      if github_event?(source_data)
        source_data['type'].camel_case
      elsif github_issue?(source_data)
        'CustomIssue'
      else
        fail Events::MappingError, 'unknown Github event type'
      end
    end

    def self.github_event?(source_data)
      not(source_data['type'].nil?)
    end

    def self.github_issue?(source_data)
      not(source_data['labels'].nil?) && not(source_data['state'].nil?) && not(source_data['comments'].nil?)
    end

    class Processor
      def initialize(response)
        @response = response
      end
      
      def parse
        @parsed ||= Yajl::Parser.parse(@response)
      end

      def extract
        parse
      end

      def decorate
      end
    end

  end
end

# Require all github types
Dir[File.join('app', 'domain', 'events', 'feeds', 'github', 'types', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end
