module Events
  module Github
    module Public
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            :title => "Repository #{original_hash['repo']['name']} goes public!"
          })
        end
      end

    end
  end
end
