require 'bits/protocol'
require_relative 'shared'

module Bits
  module Github

    class Push < Protocol
      include Shared

      def find
        @event.push_id && find_by_push_id.where(:parent_id => nil).first
      end

      def data
        with_commons({
          title: "pushed to #{@event.repo.name}",
          url: "https://github.com/#{@event.repo.name}/commit/#{@event.head}",
          origin_id: @event.push_id.to_s,
          body: format_body,
          props: {
            commit_shas: @event.commit_shas_csv,
          }
        })
      end

      def find_by_push_id
        Bit
        .feed('github')
        .type('push')
        .where(origin_id: @event.push_id.to_s)
      end

      def find_by_commit_id
        Bit
        .feed('github')
        .type('push')
        .where("props -> 'commit_shas' LIKE '%#{@event.commit_id}%'")
      end

      private

      def url
        "https://github.com/#{@event.repo.name}/commit/#{@event.head}"
      end

      def format_body
        @event.commits.map do |c|
          ["<a href=\"#{c.url}\">#{c.sha}</a>", c.author_name, c.message].join(', ')
        end.join('<br>')
      end

    end

  end
end
