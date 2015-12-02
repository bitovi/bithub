module Convenience
  module Meetup

    def venue
      "#{source_data['venue']['name']}, #{source_data['venue']['address_1']}, #{source_data['venue']['city']}"
    end

    def group_name
      "#{source_data['group']['urlname']}"
    end
  end
end
