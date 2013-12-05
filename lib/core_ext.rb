class Hash
  # File activesupport/lib/active_support/core_ext/hash/deep_merge.rb, line 14
  def deep_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
    end
    self
  end

  # File activesupport/lib/active_support/core_ext/hash/deep_merge.rb, line 9
  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end

  def project(keys)
    keys.map{|k| self[k]}
  end
end

class String
  def snake_case
    self.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      tr(".", "_").
      downcase
  end
end
