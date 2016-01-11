module Guzzler

  class Handler
    def initialize(popper)
      @popper = popper
    end

    def handle(raw_data)
      yield JSON.parse(raw_data)
    end

    def name_for_logs
      "#{self.class.name.gsub('Handler', '').upcase}_HANDLER"
    end
  end
end
