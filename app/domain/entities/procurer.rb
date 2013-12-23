module Entities
  class Procurer
    include FindableByOriginUID

    def initialize(persistor)
      @p = persistor
    end

    def dispatch(payload)
      #RECIMO issues_event koji closa issue
      meta = payload['meta']

      case 
    end

    def find_or_build(payload)
      attrs = extract(payload)

      if e = find(attrs)
        return e
      elsif e = build(attrs)
        return e
      else
        # FAIL?
      end
    end

    def find_or_build_upstream(attrs)
      attrs = extract(payload)
      Relationships[:upstream].map do |ec|
        entity = ec::Procurer.new(@p).find_or_build(attrs)
      end
    end
    
    def find_or_build_downstream(attrs)
      attrs = extract(payload)
      Relationships[:downstream].map do |ec|
        entity = ec::Procurer.new(@p).find_or_build(attrs)
      end
    end

    def extract(payload)
      payload['extracted']
    end
  end

end
