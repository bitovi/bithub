module Events
  module StackExchange
    module Accessors

      module Standard
        def link
          source_data.andand[:link]
        end

        def body
          source_data.andand[:body]
        end

        def body_markdown
          source_data.andand[:body_markdown]
        end

        def owner
          source_data.andand[:owner]
        end

        def origin_author_id
          owner.andand[:user_id]
        end

        def origin_author_name
          owner.andand[:display_name]
        end

        def origin_author_avatar_url
          owner.andand[:profile_image]
        end

        def origin_author_url
          owner.andand[:link]
        end

        def origin_ts
          creation_date
        end

        # def last_activity_date
        #   unix_ts_to_time source_dataa.andand[:last_activity_date]
        # end

        # def last_edit_date
        #   unix_ts_to_time source_dataa.andand[:last_edit_date]
        # end

        def creation_date
          unix_ts_to_time source_data.andand[:creation_date]
        end

        private

        def unix_ts_to_time(ts)
          Time.at(ts.to_i).utc
        end

      end

    end
  end
end
