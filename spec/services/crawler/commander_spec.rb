require 'celluloid/test'
require 'no_rails_spec_helper'
require 'services/crawler/commander'

describe Commander do
  before { Celluloid.boot }
  after { Celluloid.shutdown }

  describe "#message_action" do
    it "plucks the action from the message" do
      message = Hash[:action, 'restart', :brand_name, 'nikica', :feed_name, 'github']
      expect(Commander.new.message_action(message)).to eq message[:action]
    end
  end

  describe "#message_scope" do
    it "determines the scope of the action (brand and feed)" do
      message = Hash[:action, 'restart', :brand_name, 'nikica', :feed_name, 'github']
      expect(Commander.new.message_scope(message)).to eq [message[:brand_name], message[:feed_name]]
    end
  end

end
