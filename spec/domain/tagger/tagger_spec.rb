require_relative 'spec_helper'

describe Tagger do

  describe "#textualize" do
    it "untouches input string" do
      expect(Tagger.textualize("Gray fox jumps ...")).to eq "Gray fox jumps ..."
    end

    it "converts input number to string" do
      expect(Tagger.textualize(123.45)).to eq "123.45"
    end

    it "concatenates array elements into string" do
      expect(Tagger.textualize(["foo", "123", "bar"])).to eq "foo 123 bar"
    end

    it "concatenates hash values into string" do
      expect(Tagger.textualize({:foo => "foo", :num => "123", :bar => "bar"})).to eq "foo 123 bar"
    end

    it "recursively concatenates nested arrays and hashes into string" do
      input = [
        ["start"],
        {:foo => "foo", :bar => {:baz => ["baz"]}},
        "stop"
      ]
      expect(Tagger.textualize(input)).to eq "start foo baz stop"
    end
  end

  describe "#list_to_name_weight_hash" do
    it "converts array of tag names to hash of name-weight pairs" do
      input  = ['foo', '!bar']
      args   = {weight: 5}
      expect(Tagger.list_to_name_weight_hash(input, args)).to eq({"foo" => 5, "bar" => -5})
    end

    it "converts CSV list of tag names to hash of name-weight pairs" do
      input  = 'foo, !bar'
      args   = {weight: 5}
      expect(Tagger.list_to_name_weight_hash(input, args)).to eq({"foo" => 5, "bar" => -5})
    end
  end

end
