module Wrappers
  module DataAccessible

    def data_accessors(*key_names)
      key_names.each do |kn|
        instance_eval do
          define_method(kn) do
            @data.andand[kn]
          end
        end
      end
    end
  end

end
