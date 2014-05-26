require 'spec_helper'

describe Funnel do
  describe "#to_query" do
    it "returns a query data structure that represents a query that needs to be executed" do
      funnel = FactoryGirl.build(:funnel)

      expect(funnel.as_query).to eq ({
        :where => {:feed_name => "github", :type_name => "issue"},
        :tagged_with => [funnel.feed_name, funnel.type_name] + %w(bug canjs)
      })
    end
  end
end
