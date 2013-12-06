module Tagger
  class Engine
    attr_accessor :tags, :delimiters, :levenshtein_treshold

    DEFAULT_DELIMITERS = /[ ,.!?;\/]/
    DEFAULT_LEVENSHTEIN_TRESHOLD = 1

    def initialize(tags, opts={})
      @tags = tags || []
      @delimiters = opts[:delimiters] || DEFAULT_DELIMITERS
      @levenshtein_treshold = opts[:levenshtein_treshold] || DEFAULT_LEVENSHTEIN_TRESHOLD
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
        @tags.each do |tag|
          aliases = [tag[:name]]
          aliases += tag[:aliases] if tag[:aliases].is_a? Array
          leven_th = tag[:levenshtein_treshold] || @levenshtein_treshold

          aliases.each do |tag_alias|
            if Levenshtein.distance(word, tag_alias) <= leven_th
              (result << tag[:name]) unless result.include?(tag[:name])
              break
            end
          end
        end
        
        result
      end
    end

  end
end
