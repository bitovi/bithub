module Entities
  module StackExchange

    class Answer < Protocol

      def find
        @event.origin_id && find_by_origin_id
      end

      def build
        Entity.new({
          title: "answered ##{@event.question_id}", # @event.title
          body: @event.body_markdown || @event.body,
          url: @event.link,
          origin_ts: @event.creation_date,
          origin_id: @event.answer_id.to_s,
          props: {
            origin_author_id: @event.owner.id,
            origin_author_name: @event.owner.name,
            origin_author_avatar_url: @event.owner.profile_image,
            score: @event.score,
            is_accepted: @event.accepted?,
            upvote_count: @event.upvote_count,
            question_id: @event.question_id
          }
        })
      end
      
      def update
        @instance.body = @event.body_markdown || @event.body
        @instance.props[:origin_score] = @event.score
        @instance.props[:is_accepted] = @event.accepted?
        @instance.props[:upvote_count] = @event.upvote_count
        self
      end


      def build_children
        build_comments
      end

      def build_comments
        @event.comments.map do |c|
          c_e = Events::StackExchange::Comment.new(c.raw)
          Entities::StackExchange::Comment.new(c_e)
            .procure
            .determine
            .group
            .normalize
            .instance
        end
      end

      private

      def find_by_origin_id
        Entity
          .feed('stack_exchange')
          .type('answer')
          .where(origin_id: @event.answer_id.to_s)
          .first
      end

    end

  end
end
