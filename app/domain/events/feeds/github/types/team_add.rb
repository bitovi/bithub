module Events
  module Github
    module TeamAdd
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          attrs = {
            :title => "team add event"
          }
        end
      end

    end
  end
end

