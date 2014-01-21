module Events
  module Github

    class ForkApply
      include Constructable
      include Persistable
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "patch applied on #{original_hash['repo']['name']}"
#   }
# })
