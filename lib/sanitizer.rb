require 'sanitize'
require 'htmlentities'

class Sanitizer

  CUSTOM_RULESET = Sanitize::Config::RELAXED
  CUSTOM_RULESET[:elements] << "div"

  def encode(text)
    @htmlEscaper ||= HTMLEntities.new
    @htmlEscaper.encode(text)
  end

  def decode(text)
    @htmlEscaper ||= HTMLEntities.new
    @htmlEscaper.decode(text)
  end


  def self.sanitize(html)
    Sanitize.clean(html, CUSTOM_RULESET)
  end

  def self.sanitize_forum_post(html)
    doc = Nokogiri::HTML(html)
    doc.css('ol.code').each do |code|
      new_code = doc.create_element "pre"
      str = []
      code.css('li').each do |li|
        li.css('div').each do |div|
          div.inner_html = div.inner_text + "\n"
        end
        str << li.inner_text
      end
      new_code.inner_html = "<code>" + str.join("\n").strip + "</code>"
      code.replace new_code
    end

    doc.css('div pre').each do |code|
      parent = code.parent
      if parent.children.length === 1
        parent.replace code
      end
    end

    doc.css('div').each do |div|
      p = doc.create_element "p"
      p.inner_html = div.inner_html
      div.replace p
    end

    Sanitize.clean(doc.css('body').inner_html, Sanitize::Config::RELAXED)
  end

end
