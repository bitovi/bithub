module Guzzler::Persistor

  class PoppityPop

    def initialize(q_keyname, opts = {})
      @q_keyname = q_keyname
      @timeout = opts[:timeout] || 1
    end

    def redis_key
      @q_keyname
    end

    def retrieve
      _, res = Guzzler.redis { |conn| conn.brpop(@q_keyname, @timeout) }
      res
    end

  end
end
