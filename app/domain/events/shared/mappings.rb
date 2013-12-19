module Events
  module Mappings

    def feed_mappings(feed_name)
      case feed_name
      when 'forums' then 'forum'
      else feed_name
      end
    end


    def type_mappings(type_name)
      case type_name
      when 'status_event' then 'tweet'
      when 'issues_event' then 'issue_event'
      when 'IssuesEvent' then 'IssueEvent'
      when 'IssuesEvent' then 'IssueEvent'
      else type_name
      end
    end

  end
end
