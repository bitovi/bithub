module Events
  module Github
    module Member
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            :title => "Member #{event['payload']['member']['login']} added to #{event['repo']['name']}"
          })
        end
      end

    end
  end
end
