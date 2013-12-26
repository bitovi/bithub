require 'digest/md5'
require 'andand'

require 'lib/core_ext'
require 'app/domain/events/shared/mappings'

# Require all feed and type files
Dir[File.join('app', 'domain', 'events', 'feeds', '**', '*.rb')].each do |f|
  require f
end

module Events
  class Processor
    # TODO: refactor filtering so that it mutate the event with the content digest
    # it should have 1-1 mapping of digest-event in an array [[d1, e1], [d2, e2]] ...

    include Events::Mappings

    def initialize(feed)
      initialize_logger
      config = yield Hash.new if block_given?

      @feed = feed_mappings(feed)
      @subprocessor = Events.const_get(@feed.capitalize)::Processor.new{config}
    end

    def process(original_hash)
      content_digest = original_hash.delete(:content_digest)

      processed = {
        content_digest: content_digest,
        source_data: original_hash,
        meta: { feed: @feed.to_s },
        extracted: { origin_ts: origin_timestamp(original_hash) },
      }
      
      @subprocessor.process(remap_meta_type(original_hash), processed)
    end

    def content_digest(original_hash)
      @subprocessor.content_digest(original_hash)
    end

    def events_from_response(response_hash)
      @subprocessor.events_from_response(response_hash)
    end

    private

    def origin_timestamp(original_hash)
      ots = @subprocessor.origin_timestamp(original_hash)
      ots.iso8601
    end

    def to_date_str(date)
      date.strftime("%Y-%m-%d")
    end

    def remap_meta_type(original_hash)
      original_hash.deep_merge({
        meta: { type: type_mappings(original_hash[:type]) }
      })
    end

    def initialize_logger
      @logger = Log4r::Logger.new('Processor')
      @logger.add(Log4r::StdoutOutputter.new('console', {
        :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
      }))
    end

  end
end
