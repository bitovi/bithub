module Events
  module Github

    class FollowEvent
      include Constructable
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "followed #{original_hash['repo']['name']}"
#   }
# })
