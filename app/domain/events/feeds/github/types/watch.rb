module Events
  module Github
    module Watch
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            extracted: {
              :title => "started watching #{original_hash['repo']['name']}",
              #? :hash_key => Digest::MD5.hexdigest(event['actor']['id'].to_s + event['repo']['id'].to_s + 'github')
            }
          })
        end
      end

    end
  end
end
