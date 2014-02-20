require_relative 'spec_helper'

describe Tagger do

  before :all do
    import_tags
  end

  after :all do
    Tag.destroy_all
  end

  let(:tagger_config) do
    { :levenshtein_treshold => 1 }
  end

  subject(:tagger) do
    Tagger.new(Tag.projects, tagger_config)
  end

  describe "#textualize" do
    it "untouches input string" do
      expect(tagger.textualize("Gray fox jumps ...")).to eq "Gray fox jumps ..."
    end

    it "converts input number to string" do
      expect(tagger.textualize(123.45)).to eq "123.45"
    end

    it "concatenates array elements into string" do
      expect(tagger.textualize(["foo", "123", "bar"])).to eq "foo 123 bar"
    end

    it "concatenates hash values into string" do
      expect(tagger.textualize({:foo => "foo", :num => "123", :bar => "bar"})).to eq "foo 123 bar"
    end

    it "recursively concatenates nested arrays and hashes into string" do
      input = [
        ["start"],
        {:foo => "foo", :bar => {:baz => ["baz"]}},
        "stop"
      ]
      expect(tagger.textualize(input)).to eq "start foo baz stop"
    end
  end

  describe "#find_tags" do
    it "matches lowercase lexems" do
      text = "Many words ... canjs, other words jquerypp, more words steal"
      expect(tagger.find_tags(text)).to match_array %w(canjs jquerypp stealjs)
    end

    it "matches all caps lexems" do
      text = "Many words CANJS, other words JQUERYPP"
      expect(tagger.find_tags(text)).to match_array %w(canjs jquerypp)
    end

    it "matches mixed caps lexems" do
      text = "Lots of text, CanJs, a little more text StealJS"
      expect(tagger.find_tags(text)).to match_array %w(canjs stealjs)
    end

    it "matches lexems with a typo" do
      text = "Some text, then a FnucUnit, and after that, some nice nothing, and a docment_js"
      expect(tagger.find_tags(text)).to match_array %w(funcunit documentjs)
    end

    it "matches all tags found in given text" do
      text = "Lots of text, CanJs, a little more text, and then FUNCUNIT, and some jquerypp"
      expect(tagger.find_tags(text)).to match_array %w(canjs funcunit jquerypp)
    end

    it "doesn't match tokens with spaces" do
      text = "Lots of text, javascript mvc, a little more text, and then done js, and some jquery pp"
      expect(tagger.find_tags(text)).to match_array %w(javascriptmvc) #because distance(jmvc, mvc) <= 1
    end

    it "matches tags with [su|pre]fixes" do
      text = "@canjs is great, #javascriptmvc"
      expect(tagger.find_tags(text)).to match_array %w(canjs javascriptmvc)
    end

    it "handles levenstein treshold by tag" do
      text = "word tested shouldn't be matched, but @canjs should be"
      expect(tagger.find_tags(text)).to match_array %w(canjs)
    end
  end
end
