module Events
  module Github

    class Follow < Protocol
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "followed #{original_hash['repo']['name']}"
#   }
# })
