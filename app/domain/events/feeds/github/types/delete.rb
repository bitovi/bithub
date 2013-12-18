module Events
  module Github
    module Delete
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            :title => "deleted a #{original_hash['payload']['ref_type']} from #{original_hash['repo']['name']}: #{original_hash['payload']['ref']}"
          })
        end
      end

    end
  end
end
