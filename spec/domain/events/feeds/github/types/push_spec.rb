require 'domain/events/spec_helper'

describe Events::Github::Push do

  let(:raw_push) do
    raw_data(response_path: 'github/events/push_event.json')
  end

  subject(:push) do
    Events::Github::Push.new(raw_push)
  end

  pending "add some tests"

end
