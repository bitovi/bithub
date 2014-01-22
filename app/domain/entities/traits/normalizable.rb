module Entities
  module Normalizable

    def normalize
      set_thread_ts_to_origin_ts
      clean_junk_from_props
    end

    def set_thread_ts_to_origin_ts
      @instance.thread_updated_ts = @instance.origin_ts
    end

    def clean_junk_from_props
      @instance.props.delete('tags')
      @instance.props.delete('origin_author_feed') # Events from Bithub have this
    end
  end
end
