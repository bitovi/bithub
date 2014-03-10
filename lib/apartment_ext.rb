require 'apartment/adapters/postgresql_adapter'

module Apartment

  class << self
    attr_accessor :use_structure_sql
  end

  module Database
    def self.postgresql_adapter(config)
      # todo: correct mappings -> Apartment.use_schemas and Apartment.use_structure_sql ...
      Adapters::PostgresqlSchemaFromSqlAdapter.new(config)
    end
  end

  module Adapters

    class PostgresqlSchemaFromSqlAdapter < PostgresqlSchemaAdapter

      def import_database_schema
        import_structure_sql
      end

      private

      def import_structure_sql
        structure = dump_structure_sql
        processed_structure = process_structure_sql(structure)

        Apartment.connection.execute(processed_structure)
      end

      def dump_structure_sql
        dbname = ActiveRecord::Base.connection_config[:database]
        excluded_tables =
          collect_table_names(Apartment.excluded_models)
          .map! {|t| "-T #{t}"}
          .join(' ')

        `pg_dump -s -x -O -n public #{excluded_tables} #{dbname}`
      end

      def process_structure_sql(structure)
        search_path = "SET search_path = #{self.current_tenant}, pg_catalog;"

        structure
          .split("\n")
          .reject {|line| line.starts_with? "SET search_path"}
          .prepend(search_path)
          .join("\n")
      end

      def collect_table_names(models)
        models.map do |m|
          m.constantize.table_name
        end
      end
    end

  end
end

# pg_dump -s -x -O -n public -T tenants -f schema.sql bithub_development
# psql bithub_development -f schema.sql


# /home/veljko/.rbenv/versions/2.1.0/lib/ruby/gems/2.1.0/gems/activerecord-3.2.14/lib/active_record/railties/databases.rake
# 422       when /postgresql/
# 423         set_psql_env(config)
# 424         search_path = config['schema_search_path']
# 425         unless search_path.blank?
# 426           search_path = search_path.split(",").map{|search_path_part| "--schema=#{Shellwords.escape(search_path_part.strip)}" }.join(" ")
# 427         end
# 428         `pg_dump -i -s -x -O -f #{Shellwords.escape(filename)} #{search_path} #{Shellwords.escape(config['database'])}`
# 429         raise 'Error dumping database' if $?.exitstatus == 1
# 430         File.open(filename, "a") { |f| f << "SET search_path TO #{ActiveRecord::Base.connection.schema_search_path};\n\n" }
