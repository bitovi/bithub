require 'andand'
require 'core_ext'
require 'events/events'

module Events
  class FeedDeterminator
    include CoreHelpers

    def initialize(data, hint=nil)
      @data = symbolize_keys(data)
      @hint = hint
    end

    def feed_module
      if Events.constants.include?(feed_name)
        @feed_class = Events.const_get(feed_name)
      else
        fail Events::DeterminationError.new("Non-existent Event feed", feed_name)
      end
    end

    def feed_name
      raw_feed_name = @hint || @data.andand[:meta].andand[:feed_name]
      fail Events::DeterminationError.new('Determinator requires a feed_name to work.') unless raw_feed_name
      raw_feed_name.andand.camel_case.andand.to_sym
    end
      
    def source_data
      @data.fetch(:source_data)
    end
  end
end
