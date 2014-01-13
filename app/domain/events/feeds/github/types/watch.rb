module Events
  module Github

    class WatchEvent
      include Constructable
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "started watching #{original_hash['repo']['name']}",
#     #? :hash_key => Digest::MD5.hexdigest(event['actor']['id'].to_s + event['repo']['id'].to_s + 'github')
#   }
# })
