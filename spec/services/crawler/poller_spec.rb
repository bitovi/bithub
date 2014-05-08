require 'celluloid/test'
require 'no_rails_spec_helper'
require 'services/crawler/poller'

module Fetchers
  module Github
    class RepoIssues
      def fetch
        []
      end
    end
  end
end

describe Poller do
  before { Celluloid.boot }
  after { Celluloid.shutdown }

  describe "#set_interval" do
    it "changes the polling interval" do
      fetcher = Fetchers::Github::RepoIssues.new
      poller = Poller.new("nikica", fetcher, { :interval => 30 })
      expect{ poller.interval=35 }.to change{ poller.interval }.from(30).to(35)
    end
  end

  describe "#feed_name" do
    it "extracts the feed_name from the fetcher name" do
      fetcher = Fetchers::Github::RepoIssues.new
      expect(Poller.new("nikica", fetcher).feed_name).to eq "github"
    end
  end
end
