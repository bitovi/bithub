module Entities
  module Bithub
    class Post < Protocol

      def self.forge(params, current_user)
        source_data = params.clone['event'].symbolize_keys

        posting_for_another_user = !source_data[:origin_author_id].blank? &&
                                   !source_data[:origin_author_feed].blank?

        source_data[:origin_ts] = Time.now.utc unless params[:id]
        source_data[:id]        = params[:id] if params[:id]

        if !current_user.has_role?(:admin) || !posting_for_another_user
          source_data[:local_author_id] = current_user.id
        end

        if !current_user.has_role?(:admin)
          source_data.delete(:origin_author_id)
          source_data.delete(:origin_author_name)
          source_data.delete(:origin_author_feed)
        end

        ::Dispatcher.new.dispatch(source_data, 'bithub')
      end

      def find
        Entity.where(id: @event.id).first
      end

      def build
        entity = Entity.new({
          title: @event.title,
          body: @event.body,
          url: @event.url,
          origin_ts: @event.origin_ts,
          image: @event.image,
          props: {
            location: @event.location,
            project: @event.project,
            tags: @event.category,
            origin_author_id: @event.origin_author_id,
            origin_author_feed: @event.origin_author_feed,
            origin_author_name: @event.origin_author_name
          }
        })

        entity
      end

      def determine_author
        # only set user automatically to the current user if this is a new record
<<<<<<< HEAD
        if @instance.new_record? && !@event.local_author_id.nil?
          @instance.author = User.find(@event.local_author_id)
        else
          ident = Identity.find_or_create_with_provider_and_uid(
            @instance.props[:origin_author_feed],
            @instance.props[:origin_author_id]
          )
          if ident && ident.user
            @instance.author = ident.user
          else
            @instance.remove_author
          end
=======
        if @instance.new_record? && !@payload.local_author_id.nil?
          @instance.author = User.find(@payload.local_author_id)
        elsif (ident = Identity.find_or_create_with_provider_and_uid(
                @instance.props[:origin_author_feed],
                @instance.props[:origin_author_id]
              ))

          @instance.author = ident.user if ident.user
>>>>>>> master
        end
      end

      def update
        @instance.title = @event.title
        @instance.body  = @event.body
        @instance.url   = @event.url
        @instance.image = @event.image

        @instance.props[:tags] = @event.tags

        @instance.props[:scheduled_at] = @event.scheduled_at if @event.scheduled_at
        @instance.props[:location]     = @event.location if @event.location

        @instance.props[:origin_author_feed] = @event.origin_author_feed if @event.origin_author_feed
        @instance.props[:origin_author_id]   = @event.origin_author_id if @event.origin_author_id
        @instance.props[:origin_author_name] = @event.origin_author_name if @event.origin_author_name

        super
      end

    end
  end
end
