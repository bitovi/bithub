module Events
  module Facebook
    class TypeDeterminator < Events::TypeDeterminator

      def type_class
        super do 
          if Events::Facebook.constants.include? type_name
            Events::Facebook.const_get type_name
          end
        end
      end

      def type_name
        "#{source_data[:type]}_event".camel_case.to_sym
      end
    end
  end
end
