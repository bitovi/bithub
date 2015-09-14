module Guzzler
  module Util

    def watchdog(last_words)
      yield
    rescue Exception => ex
      # if respond_to? :handle_exception
      #   handle_exception(ex, { context: last_words })
      # end
      raise ex
    end
  end
end
