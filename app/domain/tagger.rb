require 'andand'
require 'levenshtein'

require 'core_ext'
require 'core_helpers'
require 'loggable'

class Tagger
  include CoreHelpers
  include Loggable
  DEFAULT_DELIMITERS = /[ ,.!?;\/]/
  DEFAULT_THRESHOLD = 1

  class NoTagsProvided < Exception; end

  class Tag
    attr_reader :name, :threshold

    def initialize(t, opts={})
      @name = t[:name]
      @aliases = t[:aliases] || []
      @threshold = t.props.andand['levenshtein_treshold'].andand.to_i || opts.andand[:threshold].andand
    end

    def names
      [@name] + @aliases
    end
  end

  def initialize(tags, opts={})
    #fail NoTagsProvided, "tagger must have tags to search for" if (tags.nil? || tags.empty?)

    @delimiters = opts[:delimiters] || DEFAULT_DELIMITERS
    @threshold = opts[:threshold] || DEFAULT_THRESHOLD
    @tags = tags.map{|t| Tag.new(t, {threshold: @threshold})} || []
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

  def tokenize(text)
    text.downcase.split(@delimiters).reject(&:empty?)
  end

  def find_tags(input)
    text = textualize(input)

    tokenize(text).reduce([]) do |result, word|
      @tags.each do |t|
        t.names.each do |name|
          if (Levenshtein.distance(word, name) <= (t.threshold || @threshold))
            (result << t.name) unless result.include?(t.name)
            break
          end
        end
      end

      result
    end
  end
end
