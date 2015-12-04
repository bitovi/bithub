module Convenience
  module Meetup

    def location
      props['location'] || ''
    end

    def group_name
      props['group_name'] || ''
    end
  end
end
