require 'domain/queries/spec_helper'

RSpec.describe QueryLogic::Query, :type => :domain do
  let(:model) do
    double("Entity", :has_an_attribute? => true )
  end

  describe ".pluck_and_process_negated_attributes" do
    it "returns all regular attrs that contain a '!' as the first character, and removes the character" do
      q = QueryLogic::Query.new(model, { exclude: "source_data", title: "!Some title", other_attr: 'An ! in the middle', feed_name: "gi!thub"})
      expect(q.pluck_and_process_negated_attributes).to eq({title: "Some title"})
    end
  end

  describe ".pluck_and_process_excluded_attributes" do
    it "plucks excluded values from the params and wraps them in an array" do
      q = QueryLogic::Query.new(model, { exclude: "source_data", title: "Some title", origin_date: "2013-01-01:2013-02-02", feed_name: "github" })
      expect(q.pluck_and_process_excluded_attributes).to eq(["source_data"])
    end
  end

  describe '.pluck_and_process_regular_params' do
    it 'applies ranges when present and leaves regular params alone' do
      q = QueryLogic::Query.new(model, { id: '1', title: 'Some title', feed_name: 'github'})
      expect(q.pluck_and_process_regular_params).to eq({id: '1', feed_name: 'github', title: 'Some title'})
    end
  end

  describe '.process_tag_based_params' do
    it 'plucks tag based items and puts them in :all buckets' do
      q = QueryLogic::Query.new(model, { id: 1, title: 'Some title', tag: 'jquerypp,stealjs' })
      expect(q.pluck_and_process_tag_based_params).to eq({all: %w(jquerypp stealjs)})
    end
    
    it "plucks tag based items and puts them in :any buckets" do
      q = QueryLogic::Query.new(model, { id: 1, title: 'Some title', tag: 'canjs|javascriptmvc' })
      expect(q.pluck_and_process_tag_based_params).to eq({any: %w(canjs javascriptmvc)})
    end
  end

end
