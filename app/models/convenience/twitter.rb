module Convenience
  module Twitter

    def has_quote?
      !props[:quoted_id].nil?
    end
    
    def has_retweet?
      !props[:retweeted_id].nil?
    end
  end
end
