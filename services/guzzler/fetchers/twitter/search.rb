require_relative 'common'

module Guzzler::Fetchers

  module Twitter
    class Search
      include Protocol
      include Twitter::Common

      def initialize(job, &blk)
        @job = job
        @blk = blk
      end
      
      def fetch
        fail ArgumenError.new('Must know how to fetch term from config') unless @blk && @blk.respond_to?(:call)

        log_fetch
        handle_errors do
          client.search(@blk.call(@job.config), :count => 100).take(100)
        end
      end

      def name_for_logs
        'Twitter/Hashtag'
      end
    end
  end
end
