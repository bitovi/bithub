namespace :data do
  task :clean_forum_posts => :environment do

    puts "---"
    puts "Cleaning body on forum posts"

    events = Event.where(category_id: 20) # question tag has id 20

    events.each do |e|      
      html = e.source_data["description"]
      
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

      sanitized = Sanitize.clean(doc.css('body').inner_html, Sanitize::Config::RELAXED)

      e.update_column('body', sanitized)
    end

    puts "Sanitized!"

  end
end
