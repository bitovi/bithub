module Events
  module Github
    module Gist
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            :title => "Gist #{original_hash['payload']['action']}: #{original_hash['payload']['gist']['description']}",
            :url => original_hash['payload']['gist']['url'],
              :meta => {
              :action => original_hash['payload']['action']
            }
          })
        end
      end

    end
  end
end
