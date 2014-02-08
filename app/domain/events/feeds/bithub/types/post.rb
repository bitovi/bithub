module Events
  module Bithub
    class Post < Protocol

      def content_digest
        calc_digest(
          title.to_s + 
          project.to_s + 
          category.to_s + 
          body.to_s +
          image.to_s +
          location.to_s +
          url.to_s +
          origin_author_id.to_s +
          tags.sort.join(',') +
          scheduled_for.to_s
        )
      end

      def id
        source_data.andand[:id]
      end

      def title
        source_data.andand[:title]
      end

      def url
        source_data.andand[:url]
      end

      def image
        source_data.andand[:image]
      end

      def body
        Sanitize.clean(source_data.andand[:body], Sanitize::Config::RELAXED)
      end

      def location
        source_data.andand[:location]
      end

      def project
        source_data.andand[:project]
      end

      def category
        source_data.andand[:category]
      end

      def scheduled_for
        source_data.andand[:datetime]
      end

      def origin_ts
        #Rails.logger.info "TIME ORIGIN TS -------------------- #{source_data.andand[:origin_ts]} source_data.andand[:origin_ts].class"
        if source_data.andand[:origin_ts].is_a? String
          Time.strptime(source_data.andand[:origin_ts], '%Y-%m-%dT%H:%M:%S%z').utc
        else
          source_data.andand[:origin_ts]
        end
      end

      def origin_author_id
        source_data.andand[:origin_author_id]
      end

      def origin_author_name
        source_data.andand[:origin_author_name]
      end

      def origin_author_feed
        source_data.andand[:origin_author_feed]
      end

      def tags
        source_data.andand[:tags] || []
      end

    end
  end
end
