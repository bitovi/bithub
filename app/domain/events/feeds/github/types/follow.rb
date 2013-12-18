module Events
  module Github
    module Follow
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            :title => "followed #{original_hash['repo']['name']}"
          })
        end
      end

    end
  end
end
