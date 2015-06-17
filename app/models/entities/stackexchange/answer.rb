require 'entities/protocol'
require_relative 'shared'

module Entities
  module Stackexchange

    class Answer < Protocol
      include Shared

      def find
        @event.answer_id && find_by_origin_id
      end

      def data
        with_commons({
          title: @event.title,
          origin_id: @event.answer_id.to_s,
          props: {
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
        build_comments.to_a
      end

      def build_comments
        @event.comments.map do |c| # Wrappers
          Events::Stackexchange::CommentEvent.new(c.raw)
        end.map do |c_e| # Events
          Entities::Stackexchange::Comment.new(c_e)
            .procure
            .determine
            .group
            .normalize
            .instance
        end if @event.comments
      end

      private

      def find_by_origin_id
        Entity
          .feed('stackexchange')
          .type('answer')
          .where(origin_id: @event.answer_id.to_s)
          .first
      end

    end

  end
end
