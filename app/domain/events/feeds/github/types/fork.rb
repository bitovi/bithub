module Events
  module Github

    class Fork < Protocol
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "forked #{original_hash['repo']['name']}"
#   }
# })
