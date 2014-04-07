module HttpHandlers
  module Protocol

    def initialize(request)
      @request = request
      yield if block_given?
    end

    def respond(args)
      status  = args[:status] || :ok
      headers = args[:headers] || {}
      body    = args[:body] || ""

      Reel::Response.new status, headers, body
    end

    private

    def body
      @require.body
    end

  end
end
