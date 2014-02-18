require 'domain/events/spec_helper'

describe Events::Github::Watch do

  let(:raw_watch) do
    raw_data(response_path: 'github/events/watch_event.json')
  end

  subject(:watch) do
    Events::Github::Watch.new(raw_watch)
  end

end
