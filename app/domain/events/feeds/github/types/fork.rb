module Events
  module Github

    class Fork
      include Constructable
      include Persistable
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "forked #{original_hash['repo']['name']}"
#   }
# })
