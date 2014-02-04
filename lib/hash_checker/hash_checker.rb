module HashChecker

  PATH_DELIMITERS = /[.]/
  
  def self.verify(definitions, target)
    failed = []
    
    definitions.each do |path, check|
      value = self.walk_path(path, target)

      if !self.verify_def(check, value)
        failed.push({
                      path: path,
                      check: check, #check.is_a?(Proc) ? check.source : check,
                      got: value
                    })
      end
    end

    return failed.empty? ? true : failed
  end

  def self.verify_def(check, value)
    if check.is_a? Proc
      check.call(value)
    elsif check.is_a? Class
      value.is_a? check
    else
      check == value
    end    
  end
  
  def self.walk_path(path, hash)
    path = path.split(PATH_DELIMITERS) if path.is_a? String
    path.reduce(hash) {|memo, attr| memo.is_a?(Hash) ? memo.andand[attr.to_sym] : false}
  end
  
  
end
