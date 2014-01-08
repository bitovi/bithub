module Events
  module Github

    class ForkApply
      include Constructable
      include Events::Github::StandardAccessors
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "patch applied on #{original_hash['repo']['name']}"
#   }
# })
