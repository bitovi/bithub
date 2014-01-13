module Events
  module Github

    class ForkEvent
      include Constructable
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "forked #{original_hash['repo']['name']}"
#   }
# })
