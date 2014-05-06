require 'no_rails_spec_helper'
require 'services/crawler/channel'

describe Channel do

  describe "#interested?" do
    it "determines if a channel is interested in the incoming message (by checking topics)"
  end

  describe "#target_text" do
    it "textualizes the received object"
  end
end
