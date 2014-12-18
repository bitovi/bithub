require 'sanitize'
require 'htmlentities'

class Sanitizer

  CUSTOM_RULESET = Sanitize::Config.merge \
    Sanitize::Config::RELAXED,
    :elements => Sanitize::Config::RELAXED[:elements] + ['div']

  def encode(text)
    @htmlEscaper ||= HTMLEntities.new
    @htmlEscaper.encode(text)
  end

  def decode(text)
    @htmlEscaper ||= HTMLEntities.new
    @htmlEscaper.decode(text)
  end

  def self.sanitize(html)
    Sanitize.fragment(html, CUSTOM_RULESET)
  end
end
