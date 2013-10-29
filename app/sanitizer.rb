require 'sanitize'
require 'htmlentities'

class Sanitizer
  
  CUSTOM_RULESET = Sanitize::Config::RELAXED
  CUSTOM_RULESET[:elements] << "div"

  def sanitize(html)
    decode(cleanup(encode(html)))
  end

  def encode(text)
    @htmlEscaper ||= HTMLEntities.new
    @htmlEscaper.encode(text)
  end

  def decode(text)
    @htmlEscaper ||= HTMLEntities.new
    @htmlEscaper.decode(text)
  end

  def cleanup(text)
    Sanitize.clean(@htmlEscaper.encode(text), CUSTOM_RULESET)
  end

end
