module Entities
  class Entity

    def find_event_by_origin_uid(uid)
      query = {
        props: { origin_author_id: uid }
      }
    end

  end
end
