require 'celluloid/test'
require 'spec_helper'
require 'services/crawler/poller/poller'

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
end
