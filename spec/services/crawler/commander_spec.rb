require 'no_rails_spec_helper'
require 'services/crawler/commander'

describe Commander do

  describe "#message_action" do
    it "determines the action the crawler needs to perform (reload|restart)"
  end

  describe "#message_scope" do
    it "determines the scope of the action (brand|feed)"
  end
end
