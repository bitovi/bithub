module Events
  module Github

    class Fork
      include Constructable
      include Events::Github::StandardAccessors
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "forked #{original_hash['repo']['name']}"
#   }
# })
