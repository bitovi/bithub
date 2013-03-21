
module Tagger
  require 'levenshtein'
  require 'sanitize'

  #class Base  

  # check if given hash has all the keys
  def self.include_keys?(hash, keys)
    (hash.keys & keys).length == keys.length
  end

  # tokenize text into array of words
  def tokenize(text, delimiter=/[ ,.!?;]/)
    text.downcase.split(delimiter).reject(&:empty?)
  end

  # search for tags within plain text
  def self.find_tags(text, tags, treshold=0)
    tokenize(text).reduce([]) do |result, word|
      tags.each do |tag|
        if Levenshtein.distance(word, tag) == treshold
          result << tag 
          break
        end
      end
      result
    end
  end

  # calculates scores for every category
  def self.calculate_scores(rules, tags)
    rules.map do |category, rule|
      {
        :name => category,
        :score => (tags & rule.keys).reduce(0) {|score, key| score += rule[key]}
      }
    end
  end

  # determines category based on tags
  def self.determine_category(rules, tags)

    # picks first one if more categories share the same score
    category = self.calculate_scores(rules, tags).max {|a,b| a[:score] <=> b[:score]}

    (category[:score] == 0) ? 'unknown' : category[:name]
  end

end
