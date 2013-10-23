require 'spec_helper'

describe Tagger do
  let(:tags) do
    {
      'canjs' => ['canjs','can_js'],
      'jquerypp' => ['jquerypp', 'jquery_pp'],
      'stealjs' => ['stealjs', 'steal_js', 'steal'],
      'funcunit' => ['funcunit'],
      'documentjs' => ['documentjs', 'document_js'],
      'javascriptmvc' => ['javascriptmvc', 'jmvc']
    } 
  end
  
  let(:tagger_config) do
    { :levenshtein_treshold => 1 }
  end

  subject(:tagger) do 
    Tagger::Engine.new(tags, tagger_config)
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
      expect(tagger.find_tags(text)).to eq %w(canjs jquerypp stealjs)
    end

    it "matches all caps lexems" do
      text = "Many words CANJS, other words JQUERYPP"
      expect(tagger.find_tags(text)).to eq %w(canjs jquerypp)
    end

    it "should match mixed caps lexems" do
      text = "Lots of text, CanJs, a little more text StealJS"
      expect(tagger.find_tags(text)).to eq %w(canjs stealjs)
    end

    it "should matche lexems with a typo" do
      text = "Some text, then a FnucUnit, and after that, some nice nothing, and a docment_js"
      expect(tagger.find_tags(text)).to eq %w(funcunit documentjs)
    end

    it "should matche all tags found in given text" do
      text = "Lots of text, CanJs, a little more text, and then FUNCUNIT, and some jquerypp"
      expect(tagger.find_tags(text)).to eq %w(canjs funcunit jquerypp)
    end
    
    it "should not match tokens with spaces" do
      text = "Lots of text, javascript mvc, a little more text, and then done js, and some jquery pp"
      expect(tagger.find_tags(text)).to eq %w(javascriptmvc) #because distance(jmvc, mvc) <= 1
    end

    it "should match tags with [su|pre]fixes" do
      text = "@canjs is great, #javascriptmvc"
      expect(tagger.find_tags(text)).to eq %w(canjs javascriptmvc)
    end
  end
  
end
