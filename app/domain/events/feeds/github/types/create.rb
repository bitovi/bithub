module Events
  module Github

    class Create
      include Constructable
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Refs
    end

  end
end

# def process(original_hash, processed)
#   processed.deep_merge({
#     extracted: {
#       :title => "created a new #{original_hash['payload']['ref_type']} on #{original_hash['repo']['name']}: #{original_hash['payload']['ref']}"
#     }
#   })
# end
