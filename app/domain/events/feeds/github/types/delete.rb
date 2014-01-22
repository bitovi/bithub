module Events
  module Github

    class Delete
      include Constructable
      include Persistable
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Refs
    end

  end
end

# def process(original_hash, processed)
#   processed.deep_merge({
#     extracted: {
#       :title => "deleted a #{original_hash['payload']['ref_type']} from #{original_hash['repo']['name']}: #{original_hash['payload']['ref']}"
#     }
#   })
# end
