module Entities
  class Normalizer
    include Loggable

    def initialize(entity)
      initialize_logger
      @e = entity
    end

    def normalize
      set_thread_ts_to_origin_ts
      clean_junk_from_props
    end

    def set_thread_ts_to_origin_ts
      @e.instance.thread_updated_ts = @e.instance.origin_ts
    end

    def clean_junk_from_props
      @e.instance.props.delete('tags')
      @e.instance.props.delete('origin_author_feed') # Events from Bithub have this
    end
  end
end
