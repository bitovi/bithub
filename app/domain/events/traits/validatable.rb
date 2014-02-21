module Events
  module Validatable
    
    def validate
      validation_methods = collect_methods(/validate_.*/)
      validation_methods.each {|m| self.send(m)}
      self
    end

  end
end
