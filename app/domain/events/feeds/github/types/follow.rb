module Events
  module Github

    class Follow
      include Constructable
      include Events::Github::StandardAccessors
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "followed #{original_hash['repo']['name']}"
#   }
# })
