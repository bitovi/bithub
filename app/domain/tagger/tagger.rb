require_relative 'tag'
require_relative 'rule'

module Tagger

  DEFAULT_DELIMITERS = /[ ,.!?;\/]/
  DEFAULT_WEIGHT = 10

  def self.textualize(input)
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

  def self.tokenize(text, delimiters=DEFAULT_DELIMITERS)
    text.downcase.split(delimiters).reject(&:empty?)
  end

  def self.list_to_name_weight_hash(tags, args={})
    tags   = tags.split(',').map {|t| t.strip} if tags.kind_of? String
    weight = args[:weight] || DEFAULT_WEIGHT || 10

    tags.inject(Hash.new) do |acc, name|
      if name.starts_with? '!'
        name = name[1..-1]
        weight = -1 * weight
      end

      acc[name] = weight
      acc
    end
  end

end
