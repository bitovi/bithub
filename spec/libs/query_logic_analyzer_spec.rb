require 'spec_helper'

describe QueryLogicAnalizer do
  let(:qla) { QueryLogicAnalizer.new(Event) }

  describe "#and_query?" do
    it "checks whether a query item is of 'AND' type" do
      query_item = ["name", "nikica,veljko"]
      expect(qla.and_query? query_item).to eq(true)
    end
  end

  describe "#or_query?" do
    it "checks whether a query item is of 'OR' type" do
      query_item = ["name", "nikica|veljko"]
      expect(qla.or_query? query_item).to eq(true)
    end
  end
  
  describe "#between_query?" do
    it "checks whether a query item is of 'BETWEEN' type" do
      query_item = ["age", "19:28"]
      expect(qla.between_query? query_item).to eq(true)
    end
  end

  describe "#tag_based_query_item?" do
    it "checks whether a query item is tag based" do
      query_item = ["feed", "twitter,github"]
      expect(qla.tag_based? query_item).to eq(true)
    end
  end

  describe "#extract_conjuctions" do
    it "extracts ANDs from a query item"
  end

  describe "#extract_alternatives" do
    it "extracts ORs from a query item" do
      query_item = ["feed", "twitter|github"]
      expect(qla.extract_alternatives query_item).to eq(["twitter", "github"])
    end
  end

  describe "#extract_range" do
    it "constructs a date range when given dates" do
      lower = "2013-1-1"; higher = "2013-5-1"
      query_item = ["origin_date", "#{lower}:#{higher}"]
      range = DateTime.parse(lower)..DateTime.parse(higher)
      expect(qla.extract_range query_item).to eq(range)
    end
    
    it "constructs an integer range when given integers" do
      query_item = ["id", "1:10"]
      expect(qla.extract_range query_item).to eq(1..10)
    end
  end
end
