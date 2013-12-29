module Events
  module Mappings

    def camel_case_names(hash)
      feed = feed_mappings(hash['feed']).camel_case
      type = type_mappings(hash['type']).gsub('_event', '').camel_case
      [feed, type]
    end

    def snake_case_names(hash)
      feed = feed_mappings(hash['feed']).snake_case_names
      type = type_mappings(hash['type']).gsub('Event', '').snake_case
      [feed, type]
    end

    def switch_to_snake_case(hash)
      hash['feed'] = feed_mappings(hash['feed']).snake_case
      hash['type'] = type_mappings(hash['type']).gsub('Event', '').snake_case
      [hash['feed'], hash['type']]
    end
    
    def switch_to_camel_case(hash)
      hash['feed'] = feed_mappings(hash['feed']).camel_case
      hash['type'] = type_mappings(hash['type']).gsub('_event', '').camel_case
      [hash['feed'], hash['type']]
    end

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
      else type_name
      end
    end

  end
end
