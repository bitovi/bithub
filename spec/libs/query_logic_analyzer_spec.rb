require 'spec_helper'

describe QueryLogicAnalyzer do
  let(:qla) { QueryLogicAnalyzer.new(Event) }
  let(:lower_date_limit_str) { "2013-1-1" }
  let(:higher_date_limit_str) { "2013-5-1" }
  let(:date_range) { DateTime.parse(lower_date_limit_str)..DateTime.parse(higher_date_limit_str) }

  describe ".pluck_excluded_attributes" do
    it "plucks excluded query items from the params" do
      params = { exclude: "source_data", title: "Some title", origin_date: "2013-01-01:2013-02-02", feed: "github", category: "code" }
      expect(qla.pluck_excluded_attributes(params)).to eq(["source_data"])
    end
  end

  describe ".pluck_regular_params" do
    it "plucks regular query items from the params" do
      params = { title: "Some title", origin_date: "2013-01-01", feed: "github", category: "code" }
      expect(qla.pluck_regular_params(params)).to eq({title: "Some title", origin_date: "2013-1-1"})
    end
  end

  describe ".process_regular_params" do
    it "applies ranges when present and leaves regular params alone" do
      params = { id: "1:10", origin_date: "2013-1-1:2013-5-1"}
      expect(qla.process_regular_params(params)).to eq({id: 1..10, origin_date: date_range})
    end
  end

  describe ".pluck_tag_based_params" do
    it "selects tag based query items from the params" do
      params = { id: 1, title: "Some title", tag: "canjs", feed: "twitter,github", category: "chat|code" }
      expect(qla.pluck_tag_based_params params).to eq({tag: "canjs", feed: "twitter,github", category: "chat|code"})
    end
  end

  describe ".process_tag_based_params" do
    it "categorises tag based attrs in any/all buckets" do
      params = { feed: "twitter,github", category: "chat|code", tag: "canjs" }
      expect(qla.process_tag_based_params params).to eq({all: ["twitter", "github", "canjs"], any: ["chat", "code"]})
    end
  end

  describe ".regular_and_valid_query_item?" do
    it "asserts that the query item's name appers in the model attributes" do
      query_item = ["title", "Some title"]
      expect(qla.regular_and_valid_query_item? query_item).to eq(true)
    end

    it "asserts that the query item's name is not of the taggable type" do
      query_item = ["feed", "github"]
      expect(qla.regular_and_valid_query_item? query_item).to eq(false)
    end
  end
  
  describe ".tag_based_query_item?" do
    it "asserts that the query item's name is of the taggable type" do
      taggable_query_item = ["feed", "twitter,github"]
      regular_query_item = ["title", "Some title"]
      expect(qla.tag_based_query_item? taggable_query_item).to eq(true)
      expect(qla.tag_based_query_item? regular_query_item).to eq(false)
    end
  end

  describe ".and_query?" do
    it "checks whether a query item is of 'AND' type" do
      query_item = ["name", "nikica,veljko"]
      expect(qla.and_query? query_item).to eq(true)
    end
  end

  describe ".or_query?" do
    it "checks whether a query item is of 'OR' type" do
      query_item = ["name", "nikica|veljko"]
      expect(qla.or_query? query_item).to eq(true)
    end
  end
  
  describe ".between_query?" do
    it "checks whether a query item is of 'BETWEEN' type" do
      query_item = ["age", "19:28"]
      expect(qla.between_query? query_item).to eq(true)
    end
  end

  describe ".extract_conjuctions" do
    it "extracts ANDs from a query item"
  end

  describe ".extract_alternatives" do
    it "extracts ORs from a query item" do
      query_item = ["feed", "twitter|github"]
      expect(qla.extract_alternatives query_item).to eq(["twitter", "github"])
    end
  end

  describe ".extract_range" do
    it "constructs a date range when given dates" do
      query_item = ["origin_date", "#{lower_date_limit_str}:#{higher_date_limit_str}"]
      expect(qla.extract_range query_item).to eq(date_range)
    end
    
    it "constructs an integer range when given integers" do
      query_item = ["id", "1:10"]
      expect(qla.extract_range query_item).to eq(1..10)
    end
  end
end
