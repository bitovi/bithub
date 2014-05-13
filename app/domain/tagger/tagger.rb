require_relative 'tag'
require_relative 'rule'


module Tagger

  DEFAULT_DELIMITERS = /[ ,.!?;\/]/

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

end
