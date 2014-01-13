module Events
  module Github

    class ForkApplyEvent
      include Constructable
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "patch applied on #{original_hash['repo']['name']}"
#   }
# })
