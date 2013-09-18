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
end
