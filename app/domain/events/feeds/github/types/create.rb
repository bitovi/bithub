module Events
  module Github
    module Create
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            :title => "created a new #{original_hash['event']['ref_type']} on #{original_hash['repo']['name']}: #{original_hash['payload']['ref']}"
          })
        end
      end

    end
  end
end
