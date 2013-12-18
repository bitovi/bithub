module Events
  module TypeMappings


    def type_mappings(meta_type)
      case meta_type
      when 'status_event' then 'tweet'
      when 'issues_event' then 'issue_event'
      when 'IssuesEvent' then 'IssueEvent'
      else meta_type
      end
    end

  end
end
