require 'entities/errors'
require 'entities/determinator'
require 'entities/shared/finders'

# Feeds
require 'entities/feeds/blog/blog'
require 'entities/feeds/disqus/disqus'
require 'entities/feeds/forum/forum'
require 'entities/feeds/github/github'
require 'entities/feeds/twitter/twitter'

module Entities
  class Procurer

    def initialize(persistor)
      initialize_logger
      @p = persistor
    end

    def procure(event, payload)
      subprocurer = Entities.const_get(event.feed)::Procurer.new(@p)
      entity = subprocurer.procure(event, payload)

      determine(entity)
      assign_common_attributes(entity)
      entity
      
      # @logger.debug "BUILT, DETERMINED #{entity.inspect}"
      # @logger.debug "BUILT, DETERMINED TAGS #{entity.tag_list.inspect}"
    end

    # -----------
    # API methods
    # -----------
    
    def determine(entity)
      @determinator ||= Determinator.new
      @determinator.determine(entity)
    end

    def find_or_build_upstream(attrs)
      attrs = attrs_from_payload(payload)
      Relationships[:upstream].map do |ec|
        entity = ec::Procurer.new(@p).find_or_build(attrs)
      end
    end
    
    def find_or_build_downstream(attrs)
      attrs = attrs_from_payload(payload)
      Relationships[:downstream].map do |ec|
        entity = ec::Procurer.new(@p).find_or_build(attrs)
      end
    end

    def attrs_from_payload(payload)
      payload['extracted']
    end

    def props_from_payload(payload)
      payload['meta']
    end

    def assign_common_attributes(entity)
      entity.thread_updated_ts = entity.origin_ts
    end

    def initialize_logger
      @logger = Log4r::Logger.new('Procurer')
      @logger.add(Log4r::StdoutOutputter.new('console', {
        :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
      }))
    end
  end
  
end


  # def self.new_from_crawler(args = {}, meta)
  #   ev = self.new(args)
  #   ev.to_props(meta).determine.group
  # end

  # def self.new_from_bithub(args)
  #   event = self.new

  #   event.hash_key = Digest::MD5.hexdigest(args[:feed] + args[:title] + args[:category] + args[:body])

  #   attrs = event.to_props_and_clean(args)
  #   event.determine
  #   event.origin_and_thread_timestamps_to_now
  #   event.assign_attributes(attrs)
  #   event.image = args[:image]
  #   event
  # end

  # def update_from_bithub(args)
  #   attrs = to_props_and_clean(args)
  #   determine
  #   assign_attributes(attrs)
  #   save
  # end

  # def origin_and_thread_timestamps_to_now
  #   now                      = DateTime.now
  #   self.origin_ts           = now.utc
  #   self.origin_date         = now.utc.to_date
  #   self.thread_updated_at   = now.utc
  #   self.thread_updated_date = now.utc.to_date
  # end
#
#
# COMMITS
#
  # def self.prepare_commit(commit_info, push_event)
  #   # custom_sd = push_event.source_data
  #   # .merge(commit_info)
  #   # .merge({type: "CustomCommitEvent"})

  #   # mf_hash = ActiveSupport::HashWithIndifferentAccess.new(custom_sd)
  #   # processed_event_hash = github_processor.process(mf_hash)
  #   # meta = processed_event_hash.delete(:meta)

  #   # [processed_event_hash, meta]
  # end
