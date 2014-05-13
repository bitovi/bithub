require_relative 'spec_helper'

describe Tagger::List do

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
end
