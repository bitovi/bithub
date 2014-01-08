module Entities

  module FindableByAuthodUID
    def find_by_origin_uid(uid)
      where("props -> 'origin_author_id' = ?", uid)
    end
  end

end
