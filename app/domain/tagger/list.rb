require_relative 'tag'
require_relative 'rule'

module Tagger
  class List

    def initialize(tags=[])
      @tags = tags.map {|t| Tag.new(t)}
      self
    end

    def best_match(rules=[])
      rules = rules.map {|r| Rule.new(r)}

      scores = rules.map do |r|
        r.rate(@tags)
      end

      scores.max {|a,b| a <=> b}
    end

    def taggify(input)
      text = Tagger.textualize(input)

      Tagger.tokenize(text).reduce([]) do |result, word|
        @tags.each do |t|
          t.names.each do |name|
            if (Levenshtein.distance(word, name) <= t.tolerance)
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
