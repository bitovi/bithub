module Events
  module Github
    module TeamAdd
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            extracted: {
              :title => "team add event"
            }
          })
        end
      end

    end
  end
end

