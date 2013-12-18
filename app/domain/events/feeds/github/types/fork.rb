module Events
  module Github
    module Fork
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            :title => "forked #{original_hash['repo']['name']}"
          })
        end
      end

    end
  end
end
