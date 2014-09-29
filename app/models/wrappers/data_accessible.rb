module Wrappers
  module DataAccessible

    def raw
      @data
    end

    module ClassMethods
      def data_accessors(*key_names)
        key_names.each do |key_name|
          instance_eval do
            define_method(key_name) do
              @data.fetch(key_name)
            end
          end
        end
      end

      # Will fail if data is not available
      def has(*key_names)
        key_names.each do |key_name|
          instance_eval do
            define_method(key_name) do
              @data.fetch(key_name)
            end
          end
        end
      end

      # Will return nil if data is not available
      def maybe_has(*key_names)
        key_names.each do |key_name|
          instance_eval do
            define_method(key_name) do
              @data[key_name]
            end
          end
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

  end

end
