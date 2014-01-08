module Events
  module Github

    class Public
      include Constructable
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "Repository #{original_hash['repo']['name']} goes public!"
#   }
# })
