class IndifferentHstore
  def self.load(hash)
    HashWithIndifferentAccess.new hash
  end

  def self.dump(value)
    value
  end
end
