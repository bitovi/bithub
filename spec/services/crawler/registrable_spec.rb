require 'no_rails_spec_helper'
require 'services/crawler/streamers/all'
require 'services/crawler/streamers/registrable'

describe Streamers::Registrable do

  describe "#register" do
    it "adds the channel to list of subscribers"
  end

  describe "#unregister" do
    it "removes the channel from the list of subscribers"
  end

  describe "#route" do
    it "routes the message to the appropriate channel"
  end
end
