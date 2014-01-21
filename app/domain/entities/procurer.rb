require 'entities/modules/constructable'
require 'entities/modules/determinable'

module Entities

  class Procurer
    class DelegationError < Exception; end
    include Loggable

    def initialize(payload)
      initialize_logger
      construct_entity(payload)
    end
    
    def method_missing(method, *args, &block)
      if @entity.respond_to? method
        @entity.send(method, *args, &block)
      else
        fail DelegationError, "#{@entity_class} doesn't respond to #{method}"
      end
    end
    
    private
    def construct_entity(payload)
      @entity_class  = Entities.feed(payload.feed).type(payload.type)
      @entity ||= @entity_class.new(payload)
    end
  end
end

# Feeds
require 'entities/feeds/blog/blog'
require 'entities/feeds/disqus/disqus'
require 'entities/feeds/forum/forum'
require 'entities/feeds/github/github'
require 'entities/feeds/twitter/twitter'
require 'entities/feeds/meetup/meetup'


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



    # def extract_type_name(_class)
    #   name = _class.to_s; levels = name.scan(/::/).count
    #   # @logger.debug "Extracting for #{name}"
    #   if levels == 2
    #     _, type_name = name.match(/.*::(.*)$/)
    #   elsif levels == 3
    #     _, type_name = name.match(/.*::(.*)::.*$/).to_a
    #   end
    #   type_name if type_name
    # end

# module Entities
# 	module Helpers
# 		def feed_type_names(event)
# 			_, feed, type = event.class.to_s.match(/.*::(.*)::(.*)/).to_a
#       [feed, type]
# 		end
# 	end
# end
