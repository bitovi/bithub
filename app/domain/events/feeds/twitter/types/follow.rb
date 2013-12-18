module Events
  module Twitter
    module Follow
      #Relationships = [Entities::Twitter::Follow]

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            title: "followed @#{original_hash['target']['screen_name']}",
            # hash_key: Digest::MD5.hexdigest(original_hash['source']['id_str'] + original_hash['target']['id_str'] + @feed.to_s),
            meta: {
              type: 'follow_event',
              origin_author_name: original_hash['source']['screen_name'],
              origin_author_id: original_hash['source']['id'],
            }
          })
        end
      end

    end
  end
end
