require 'domain/queries/spec_helper'

RSpec.describe QueryLogic::QueryItem, :type => :domain do

  let(:model) { double("Entity", :has_an_attribute? => true )}

  describe "#value" do
    it "should cast query values to appropriate type (which it has to read from column info)"
  end

  describe "#negation?" do
    it "asserts that the query item is negated and is native" do
      expect(QueryLogic::QueryItem.new(model, ["title", "!Some title"]).negation?).to eq(true)
    end
  end

  describe "#regular_and_valid?" do
    it "confirms that non-tag-based items are regular" do
      expect(QueryLogic::QueryItem.new(model, ["title", "Some title"]).regular_and_valid?).to eq(true)
    end

    it "denies that tag_based items are regular" do
      expect(QueryLogic::QueryItem.new(model, ["tag", "github"]).regular_and_valid?).to eq(false)
    end
  end

  describe "#tag_based?" do
    let(:tag_model) do
      double("Entity", :tag_based_attrs => %w(feed type category project))
    end

    it "confirms that attributes that are stored as tags are of the taggable type" do
      expect(QueryLogic::QueryItem.new(tag_model, ["feed", "twitter,github"]).tag_based?).to eq(true)
    end

    it "denies that regular attributes are of the taggable type" do
      expect(QueryLogic::QueryItem.new(tag_model, ["title", "Some title"]).tag_based?).to eq(false)
    end
  end

  describe "#native?" do
    it "confirms that regular items are indeed native" do
      expect(QueryLogic::QueryItem.new(model, ["title", "Some title"]).native?).to eq(true)
    end

    it "confirms that tag based items are also native (via associations)" do
      expect(QueryLogic::QueryItem.new(model, ["feed", "twitter,github"]).native?).to eq(true)
    end

    it "denies that non existent query items are native" do
      model = double("Entity", :has_an_attribute? => false)
      expect(QueryLogic::QueryItem.new(model, ["not_existing", "non_existent_value"]).native?).to eq(false)
    end
  end

  describe "#and_value?" do
    it "checks whether a query item is of 'AND' type" do
      expect(QueryLogic::QueryItem.new(model, ["name", "nikica,veljko"]).and_value?).to eq(true)
    end
  end

  describe "#or_value?" do
    it "checks whether a query item is of 'OR' type" do
      expect(QueryLogic::QueryItem.new(model, ["name", "nikica|veljko"]).or_value?).to eq(true)
    end
  end

  describe "#between_value?" do
    it "checks whether a query item is of 'BETWEEN' type" do
      expect(QueryLogic::QueryItem.new(model, ["age", "19:28"]).between_value?).to eq(true)
    end
  end

  describe "#extract_conjuctions" do
    it "extracts ANDs from a query item"
  end

  describe "#extract_alternatives" do
    it "extracts ORs from a query item" do
      expect(QueryLogic::QueryItem.new(model, ["feed", "twitter|github"]).extract_alternatives).to eq(["twitter", "github"])
    end
  end

  describe "#extract_range" do
    let(:lower_date_limit_str) { "2013-1-1" }
    let(:higher_date_limit_str) { "2013-5-1" }
    let(:date_range) { DateTime.parse(lower_date_limit_str)..DateTime.parse(higher_date_limit_str) }

    it "constructs an integer range when given integers" do
      column_info = double("id", :type => :integer)
      model = double("Entity", :columns_hash => {"id" => column_info})

      expect(QueryLogic::QueryItem.new(model, ["id", "1:10"]).extract_range).to eq(1..10)
    end

    it "constructs a date range when given dates" do
      column_info = double("origin_date", :type => :datetime)
      model = double("Entity", :columns_hash => {"origin_date" => column_info})

      expect(QueryLogic::QueryItem.new(model, ["origin_date", "#{lower_date_limit_str}:#{higher_date_limit_str}"]).extract_range).to eq(date_range)
    end
  end

end
