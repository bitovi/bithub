require_relative 'accessors'

module Events
  module Github
    class CommitComment; end
    class Create; end
    class CustomIssue; end
    class Delete; end
    class Download; end
    class Follow; end
    class Fork; end
    class ForkApply; end
    class Gist; end
    class Gollum; end
    class Issue; end
    class IssueComment; end
    class Member; end
    class Public; end
    class PullRequest; end
    class PullRequestReviewComment; end
    class PullRequestReviewComment; end
    class Push; end
    class TeamAdd; end
    class Watch; end

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
        source_data['type']
      elsif github_issue?(source_data)
        'custom_issue_event'
      else
        fail Events::Errors::UnknownTypeException
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
    end

  end
end

# Require all github types
Dir[File.join('app', 'domain', 'events', 'feeds', 'github', 'types', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end
