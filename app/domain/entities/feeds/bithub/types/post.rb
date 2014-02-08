module Entities
  module Bithub
    class Post < Protocol

      def self.forge(params, current_user)
        source_data = params.clone['event'].symbolize_keys

        posting_for_another_user = !source_data[:origin_author_id].blank? &&
                                   !source_data[:origin_author_feed].blank?

        source_data[:origin_ts] = Time.now.utc unless params[:id]
        source_data[:id]        = params[:id] if params[:id]

          # handle post-as
        if !current_user.has_role?(:admin) || !posting_for_another_user
          source_data[:local_author_id] = current_user.id
          #source_data[:origin_author_feed] = 'bithub'
        end

        Rails.logger.info "-------------------------------------------"
        Rails.logger.info source_data
        Rails.logger.info "-------------------------------------------"


        data = {
          source_data: source_data,
          meta: {
            feed_name: 'bithub',
            type: 'post'
          }
        }

        ::Dispatcher.new.dispatch(data)
      end

      def find
        Entity.where(id: @payload.id).first
      end

      def build
        entity = Entity.new({
          title: @payload.title,
          body: @payload.body,
          url: @payload.url,
          origin_ts: @payload.origin_ts,
          image: @payload.image,
          props: {
            scheduled_for: @payload.scheduled_for,
            location: @payload.location,
            project: @payload.project,
            tags: @payload.category,
            origin_author_id: @payload.origin_author_id,
            origin_author_feed: @payload.origin_author_feed,
            origin_author_name: @payload.origin_author_name
          }
        })

        

        entity
      end

      def determine_author
        unless @payload.local_author_id.nil?
          @instance.author = User.find(@payload.local_author_id)
        else
          ident = Identity.find_or_create_with_provider_and_uid(
            @instance.props[:origin_author_feed],
            @instance.props[:origin_author_id]
          )
          @instance.author = ident.user if ident && ident.user
        end
      end

      def update
        @instance.title = @payload.title
        @instance.body = @payload.body
        @instance.url = @payload.url
        @instance.image = @payload.image
        @instance.props[:scheduled_for] = @payload.scheduled_for
        @instance.props[:location] = @payload.location
        @instance.props[:tags] = @payload.tags
        super
      end

    end
  end
end
