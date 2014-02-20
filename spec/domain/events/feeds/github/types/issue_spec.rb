require 'domain/events/spec_helper'

describe Events::Github::Issue do

  let(:raw_issue) {
    raw_data(response_path: 'github/events/issues_event.json')
  }

  subject(:issue) do
    Events::Github::Issue.new(raw_issue)
  end

  pending "add some tests"

end
