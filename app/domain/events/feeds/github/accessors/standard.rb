module Events
  module Github
    module Accessors

      module Standard
        def event_id
          source_data.andand[:id]
        end

        def payload
          source_data.andand[:payload]
        end

        def action
          payload.andand[:action]
        end

        def actor
          @actor ||= Accessors::Actor.new(source_data.andand[:actor])
        end

        def repo
          @repo ||= Accessors::Repo.new(source_data.andand[:repo])
        end

        def origin_ts
          ts_str = source_data.andand[:created_at]
          Time.parse(ts_str).utc
        end
      end

    end

  end
end
