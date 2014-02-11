module Events
  module Bithub
    module Postlike; end
    class Post < Protocol; end
    class Event < Protocol; end

    def self.type(source_data)
      type_name = extract_type_name(source_data)

      if self.constants.include?(type_name)
        self.const_get(type_name)
      else
        fail MappingError.new("Couldn't find valid type for Bithub", type_name)
      end
    end

    def self.extract_type_name(source_data)
      (source_data.symbolize_keys.andand[:meta].symbolize_keys.andand[:type] ||
       source_data.symbolize_keys.andand[:meta].symbolize_keys.andand[:type_name])
    end

  end
end


require_relative 'traits/postlike'
require_relative 'types/post'
require_relative 'types/event'