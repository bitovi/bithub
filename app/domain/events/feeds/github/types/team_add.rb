module Events
  module Github

    class TeamAddEvent
      include Constructable
      include Events::Github::Accessors::Standard
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "team add event"
#   }
# })
