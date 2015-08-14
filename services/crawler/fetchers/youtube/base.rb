require_relative 'errors'

module Fetchers
  module Youtube

    class Base
      include Protocol

      def initialize(client, opts={})
        @client = client
        @opts   = opts
      end

      def fetch(&block)
        handle_errors do
          result = yield if block_given?

          if result.error?
            err_code = result.data.error['code']
            err_msg  = result.data.error['message']
            msg      = "#{err_code} #{err_msg}"

            case err_code
            when 400
              raise BadRequestError.new msg
            when 403
              raise (/.*quota.*/i.match(err_msg) ? QuotaExceeded.new(msg) : ForbiddenError.new(msg))
            else
              raise msg
            end
          else
            result.data.items.map {|i| i.to_hash}
          end
        end
      end

      def youtube_api
        @youtube_api ||= @client.discovered_api 'youtube', 'v3'
      end

    end
  end
end
