require 'domain/events/spec_helper'

describe Events::Github::CustomIssue do

  let(:raw_custom_issue) do
    raw_data(response_path: 'github/issues/issues_list.json')
  end

  subject(:custom_issue) do
    Events::Github::CustomIssue.new(raw_custom_issue)
  end

end
