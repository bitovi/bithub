require 'entities/errors'
require 'entities/determinator'
require 'entities/shared/procurement_api'
require 'entities/shared/finders'
require 'entities/shared/accessors'
require 'entities/shared/helpers'

module Entities

  class Procurer
    include Loggable

    def initialize(persistor, payload)
      initialize_logger
      @persistor = persistor
      @subprocurer = procurer(payload)
    end

    def procure(payload)
      @logger.debug "Procurer#procure for:#{extract_type_name(self.class)}, payload:#{payload.type}" 
      procurer.procure(payload)
    end
    
    def find_upstream(payload)
      procurer.find_upstream(payload)
    end

    def find_downstream(payload)
      procurer.find_downstream(payload)
    end
    
    def find_references(payload)
      procurer.find_references(payload)
    end
    
    private
    def procurer(payload)
      @subprocurer ||= Entities
        .const_get(payload.type)
        .const_get(payload.type)
        ::Procurer.new(@persistor)
    end

    def build_fail(payload)
      @logger.error "Don't know how to build for payload #{payload}"
      fail Entities::Errors::BuildingError, "don't know how to build the entity from the supplied payload"
    end
  end
  
  module Github; end
  module Twitter; end
  module Forum; end
  module Blog; end
  module Disqus; end
  module Meetup; end
end

# Feeds
require 'entities/feeds/blog/blog'
require 'entities/feeds/disqus/disqus'
require 'entities/feeds/forum/forum'
require 'entities/feeds/github/github'
require 'entities/feeds/twitter/twitter'


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



      # if own_type?(type(payload))
      #   find_self(payload)
      # elsif downstream_type?(type(payload))
      #   find_as_parent(payload)
      # elsif upstream_type?(type(payload))
      #   find_as_children(payload)
      # elsif reference_type?(type(payload))
      #   find_references(payload)
      # end



    # def own_type?(type)
    #   #@logger.debug "Procurer#own_type #{type} #{module_name}"
    #   extract_type_name(self.class) == type
    # end
    
    # def among_relationships?(type)
    #   upstream_type?(type) || downstream_type?(type) || referenced_type?
    # end

    # def upstream_type?(type)
    #   @logger.debug "Procurer#upstream_type? for:#{extract_type_name(self.class)}, payload:#{type}" 
    #   relationships[:upstream]
    #   .map {|rl| extract_type_name(rl)}
    #   .include?(type)
    # end

    # def downstream_type?(type)
    #   @logger.debug "Procurer#downstream_type? for:#{extract_type_name(self.class)}, payload:#{type}" 
    #   relationships[:downstream]
    #   .map {|rl| extract_type_name(rl)}
    #   .include?(type)
    # end
    
    # def downstream_type?(type)
    #   @logger.debug "Procurer#refereced_type? for:#{extract_type_name(self.class)}, payload:#{type}" 
    #   relationships[:references]
    #   .map {|rl| extract_type_name(rl)}
    #   .include?(type)
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
