module Events
  module Github
    module Gollum
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          attrs = {
            :title => "wiki updated on #{original_hash['repo']['name']}",
            :meta => { :pages => [] }
          }

          original_hash['payload']['pages'].each do |page|
            attrs[:meta][:pages].push({:title => page['title'], :url => page['html_url']})
          end

          processed.deep_merge(attrs)
        end
      end

    end
  end
end
