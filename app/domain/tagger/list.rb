require_relative 'tag'
require_relative 'rule'

module Tagger
  class List

    def initialize(tags=[])
      @tags = tags.map {|t| Tag.new(t)}
      self
    end

    def best_match(rules=[])
      scores = rules.map do |r|
        Rule.new(r).rate(@tags)
      end

      score, idx = scores.each_with_index.max
      idx.class == Fixnum ? rules[idx] : nil
    end

    def taggify(input)
      text = Tagger.textualize(input)

      Tagger.tokenize(text).reduce([]) do |result, word|
        @tags.each do |t|
          t.names.each do |name|
            if Levenshtein.distance(word, name) <= t.tolerance
              (result << t.name) unless result.include?(t.name)
              break
            end
          end
        end

        result
      end
    end

  end
end
