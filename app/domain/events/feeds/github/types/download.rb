module Events
  module Github
    module Download
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            extracted: {
              :title => "download #{original_hash['payload']['download']['name']} created",
              :body => original_hash['payload']['download']['description'],
              :url => original_hash['payload']['download']['html_url'],
            }
          })
        end
      end

    end
  end
end
