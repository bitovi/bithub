module Tagger
  class NoTagsProvided < Exception; end
  class Engine
    attr_reader :count
    attr_accessor :tags, :delimiters, :levenshtein_treshold

    DEFAULT_DELIMITERS = /[ ,.!?;\/]/

    def initialize(tags, opts={})
      fail Tagger::NoTagsProvided, "tagger must have tags to search for" if tags.nil? || tags.empty?

      @count = 0
      @tags = tags
      @levenshtein_treshold = opts[:levenshtein_treshold] || 0
      @delimiters = opts[:delimiters] || DEFAULT_DELIMITERS
    end

    def textualize(input)
      text = []

      if input.is_a?(Array)
        input.each {|elem| text.push textualize(elem) }
      elsif input.is_a?(Hash)
        input.each {|k,v| text.push textualize(v) }
      else
        text.push input.to_s
      end

      text.join(' ')
    end

    # tokenize text into array of words
    def tokenize(text)
      text.downcase.split(delimiters).reject(&:empty?)
    end

    # search for tags within plain text
    def find_tags(input)
      text = textualize(input)

      tokenize(text).reduce([]) do |result, word|
        @tags.each do |t|
          names = [t.name]; names += t.aliases if t.aliases
          names.each do |name|
            if Levenshtein.distance(word, name) <= @levenshtein_treshold
              (result << t.name) if !result.include?(t.name)
              break
            end
          end
        end
        result
      end
    end

  end
end
