require 'yajl'
require 'levenshtein'

module Tagger
  class Base
    attr_reader :count, :exchange
    attr_accessor :rules, :tags, :delimiter, :levenshtein_treshold

    DELIMITER = /[ ,.!?;\/]/
    FAILOVER_CATEGORY = 'unknown'

    # check if given hash has all the keys
    def self.include_keys?(hash, keys)
      (hash.keys & keys).length == keys.length
    end

    def initialize(exchange, rules, tags, logger=nil, levenshtein_treshold=nil, delimiter=nil)
      @count = 0
      @exchange = exchange
      @rules = rules
      @tags = tags
      #@logger = logger
      @levenshtein_treshold ||= 0
      @delimiter ||= DELIMITER
    end

    # tokenize text into array of words
    def tokenize(text)
      text.downcase.split(@delimiter).reject(&:empty?)
    end
    
    # search for tags within plain text
    def find_tags(text)
      tokenize(text).reduce([]) do |result, word|
        @tags.each do |tag|
          if Levenshtein.distance(word, tag) <= @levenshtein_treshold
            (result << tag) if !result.include?(tag)
            break
          end
        end
        result
      end
    end
    
    # calculates scores for every category
    def calculate_scores(tags)
      @rules.map do |category, rule|
        {
          :name => category,
          :score => (tags & rule.keys).reduce(0) {|score, key| score += rule[key]}
      }
      end
    end
    
    # determines category based on tags
    def determine_category(tags)
      
      # picks first one if more categories share the same score
      category = self.calculate_scores(tags).max {|a,b| a[:score] <=> b[:score]}
      
      (category[:score] == 0) ? FAILOVER_CATEGORY : category[:name]
    end

  end
end


