require 'domain/spec_helper'

RSpec.describe Tagger::List, :typo => :tagger do

  subject(:tagger) do
    tags = [
            {name: 'canjs'},
            {name: 'documentjs',    aliases: ['document_js']},
            {name: 'funcunit',      aliases: ['func_unit']},
            {name: 'javascriptmvc', aliases: ['jmvc','java_script_mvc']},
            {name: 'jquerypp',      aliases: ['j_querypp','j_query++','jquery++']},
            {name: 'stealjs',       aliases: ['steal','steal_js']},
           ]

    Tagger::List.new(tags)
  end

  subject(:rule1) { {required_tags: {'canjs' => 10} } }
  subject(:rule2) { {required_tags: {'j_querypp' => 5} } }
  subject(:rule3) { {required_tags: {'stealjs' => 5, 'funcunit' => 5} } }

  describe "#taggify" do
    it "matches lowercase lexems" do
      text = "Many words ... canjs, other words jquerypp, more words steal"
      expect(tagger.taggify(text)).to match_array %w(canjs jquerypp stealjs)
    end

    it "matches all caps lexems" do
      text = "Many words CANJS, other words JQUERYPP"
      expect(tagger.taggify(text)).to match_array %w(canjs jquerypp)
    end

    it "matches mixed caps lexems" do
      text = "Lots of text, CanJs, a little more text StealJS"
      expect(tagger.taggify(text)).to match_array %w(canjs stealjs)
    end

    it "matches lexems with a typo" do
      text = "Some text, then a FnucUnit, and after that, some nice nothing, and a docment_js"
      expect(tagger.taggify(text)).to match_array %w(funcunit documentjs)
    end

    it "matches all tags found in given text" do
      text = "Lots of text, CanJs, a little more text, and then FUNCUNIT, and some jquerypp"
      expect(tagger.taggify(text)).to match_array %w(canjs funcunit jquerypp)
    end

    it "doesn't match tokens with spaces" do
      text = "Lots of text, javascript mvc, a little more text, and then done js, and some jquery pp"
      expect(tagger.taggify(text)).to match_array %w(javascriptmvc) #because distance(jmvc, mvc) <= 1
    end

    it "matches tags with [su|pre]fixes" do
      text = "@canjs is great, #javascriptmvc"
      expect(tagger.taggify(text)).to match_array %w(canjs javascriptmvc)
    end

    it "handles levenstein treshold by tag" do
      text = "word tested shouldn't be matched, but @canjs should be"
      expect(tagger.taggify(text)).to match_array %w(canjs)
    end
  end

  describe "#best_match" do
    it "matches tag name" do
      expect(tagger.best_match([rule1])).to eq(rule1)
    end

    it "matches tag by alias" do
      expect(tagger.best_match([rule2])).to eq(rule2)
    end

    it "matches last rule with same value" do
      expect(tagger.best_match([rule3, rule2, rule1])).to eq(rule1)
      expect(tagger.best_match([rule1, rule3, rule2])).to eq(rule3)
    end
  end

end
