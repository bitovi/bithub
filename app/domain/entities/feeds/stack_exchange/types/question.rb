module Entities
  module StackExchange

    class Question < Protocol

      def find
        @event.question_id && find_by_question_id
      end

      def build
        Entity.new({
          title: @event.title,
          body: @event.body_markdown || @event.body,
          url: @event.link,
          origin_ts: @event.creation_date,
          origin_id: @event.question_id.to_s,
          props: {
            origin_author_id: @event.owner.id,
            origin_author_name: @event.owner.name,
            origin_author_avatar_url: @event.owner.profile_image,
            score: @event.score,
            accepted_answer_id: @event.accepted_answer_id,
            upvote_count: @event.upvote_count,
          }
        })
      end
      
      def update
        @instance.title = @event.title
        @instance.body = @event.body_markdown || @event.body
        @instance.props[:score] = @event.score
        @instance.props[:upvote_count] = @event.upvote_count
        @instance.props[:accepted_answer_id] = @event.accepted_answer_id

        # ?!?!
        update_children
        self
      end

      def build_children
        build_comments + build_answers
      end

      def update_children
        update_answers
      end

      private

      def build_answers
        @event.answers.map do |a|
          event = Events::StackExchange::Answer.new(a.raw)
          Entities::StackExchange::Answer.new(a)
            .procure.determine.group.normalize.instance
        end if @event.answers
      end

      def build_comments
        @event.comments.map do |c|
          c_e = Events::StackExchange::Answer.new(c.raw)
          Entities::StackExchange::Comment.new(c_e)
            .procure.determine.group.normalize.instance
        end if @event.comments
      end

      def update_answers
        @event.answers.map do |a|
          a_e = Events::StackExchange::Answer.new(a.raw)
          Entities::StackExchange::Answer.new(a_e)
            .procure.update.determine.group.normalize.persist
        end if @event.answers
      end

      def find_by_question_id
        Entity
          .feed('stack_exchange')
          .type('question')
          .where(origin_id: @event.question_id.to_s)
          .first
      end

    end
  end
end
