require 'domain/events/spec_helper'

describe Events::Github::Fork do

  let(:raw_fork) do
    raw_data(response_path: 'github/events/fork_event.json')
  end

  subject(:fork) do
    Events::Github::Fork.new(raw_fork)
  end

  pending "add some tests for Events::Github::Fork"

end
