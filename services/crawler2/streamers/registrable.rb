module Streamers
  module Registrable

    def register(filter)
      if @filters.select{|f| f.name == filter.name}.empty?
        @filters << filter
        reconnect
      end
    end

    def unregister(filter)
      if @filters.reject!{|f| f.name == filter.name}
        reconnect
      end
    end

  end
end
