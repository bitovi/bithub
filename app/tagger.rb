
module Tagger
  require 'levenshtein'
  require 'sanitize'

  #class Base

  # check if given hash has all the keys
  def self.include_keys?(hash, keys)
    (hash.keys & keys).length == keys.length
  end

  # tokenize text into array of words
  def tokenize(text, delimiter=/[ ,.!?;]/)
    text.split(delimiter).reject(&:empty?).map {|w| w.downcase }
  end

  # search for tags within plain text
  def self.find_tags(text, tags, treshold=0)
    tokenize(text).reduce([]) do |result, word|
      tags.each do |tag|
        if Levenshtein.distance(word, tag) == treshold
          result << tag 
          break
        end
      end
      result
    end
  end

  # determines category based on tags
  def self.determine_category(tags)
    
    case
    when tags.include?('twitter')
      case 
      when tags.include?('follow_event') 
        'digest'
      else 'twitter'
      end
      
    when tags.include?('github')
      case
      when (tags & ['commit_comment_event', 'issue_comment_event', 'pull_request_review_comment_event']).any?
        'comment'
      when (tags & ['fork_event', 'watch_event']).any?
        'digest'
      when (tags & ['push_event', 'create_event', 'delete_event', 'pull_request_event']).any?
        'code'
      when (tags & ['feature', 'feature-request','enhancement']).any?
        'feature'
      when tags.include?('question')
        'question'
      when tags.include?('bug')
        'bug'
      end

    when tags.include?('irc')
      'chat'

    when tags.include?('disqus')
      'comment'

    when tags.include?('blog')
      'article'
      
    when tags.include?('forums')
      'question'

    else false
    end

  end

end
