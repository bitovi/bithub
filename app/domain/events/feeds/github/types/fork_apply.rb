module Events
  module Github
    module ForkApply
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            extracted: {
              :title => "patch applied on #{original_hash['repo']['name']}"
            }
          })
        end
      end

    end
  end
end
