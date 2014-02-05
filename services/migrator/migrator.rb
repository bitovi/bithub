MIGRATOR_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
ROOT_DIR = File.expand_path(File.join(MIGRATOR_DIR, '..', '..'))
DOMAIN_DIR = File.join(ROOT_DIR, 'app', 'domain')

$:.unshift(ROOT_DIR)
$:.unshift(DOMAIN_DIR)

require 'pg'
require 'yajl'
require 'amqp'
require 'ostruct'
require 'log4r'
require 'andand'
require 'awesome_print'

require 'core_ext'
require 'core_helpers'
require 'app/domain/events/dispatcher'

### Config

$db_config = {
  :dbname => 'bithub_staging',
  :user => 'veljko',
  :password => 'negativ1Q'
}

$amqp_conn_string = "amqp://bithub:Ei7PhaaH@localhost/bithub"

$queries = {
  github: "SELECT source_data FROM events, taggings WHERE events.id=taggings.taggable_id AND taggings.tag_id=1 LIMIT 1"
}


### Handlers

def handle_db_row(row)
  sd = Yajl::Parser.new.parse(row['source_data'])
  ev = Events::Dispatcher.dispatch(sd, 'github')
  
  {
    source_data: ev.source_data,
    content_digest: ev.content_digest,
    meta: {
      feed: ev.feed,
      type: ev.type
    }          
  }
end

def handle_db_result(result, &blk)
  result.each do |row|
    blk.call(handle_db_row(row))
  end
end

def check_shell_argvs
  queries = []
  missing = []

  ARGV.each do |arg|
    if query = $queries.andand[arg.to_sym]
      queries.push(query)
    else
      missing.push(arg)
    end
  end

  if queries.empty? || !missing.empty?
    puts "Available queries:"
    $queries.each {|k,v| puts "  - #{k}"}
  end
  
  queries.uniq
end

### Init

logger = Log4r::Logger.new('Migrator')
logger.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

queries = check_shell_argvs
exit(1) if queries.empty?

###

pg_conn = PG.connect($db_config)

AMQP.start($amqp_conn_string) do |amqp_conn, open_ok|
  logger.info "Connected to AMQP broker on #{amqp_conn.settings[:host]}:#{amqp_conn.settings[:port]}"

  stop = proc { logger.info "Terminating the listener"; pg_conn.close; amqp_conn.close { EM.stop }}
  Signal.trap("INT",  &stop)
  Signal.trap("TERM", &stop)

  channel = AMQP::Channel.new(amqp_conn)
  channel.direct("e.events") do |exchange|
    queries.each do |q|
      puts "Executing: #{q}"
      pg_conn.exec($queries[:github]) do |result|
        handle_db_result result do |ev|
          exchange.publish(Yajl::Encoder.encode(ev))
        end
      end
    end
  end
end
