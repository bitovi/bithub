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
        clone_pg_schema
        copy_schema_migrations
      end

      private

      def clone_pg_schema
        pg_schema_sql = patch_search_path(pg_dump_schema)
        Apartment.connection.execute(pg_schema_sql)
      end

      def copy_schema_migrations
        pg_migrations_data = patch_search_path(pg_dump_schema_migrations_data)
        Apartment.connection.execute(pg_migrations_data)
      end

      def pg_dump_schema
        dbname = ActiveRecord::Base.connection_config[:database]

        # excluded_tables =
        #   collect_table_names(Apartment.excluded_models)
        #   .map! {|t| "-T #{t}"}
        #   .join(' ')

        # `pg_dump -s -x -O -n public #{excluded_tables} #{dbname}`

        `pg_dump -s -x -O -n public #{dbname}`
      end

      def pg_dump_schema_migrations_data
        `pg_dump -a --inserts -t schema_migrations -n public bithub_development`
      end

      def patch_search_path(sql)
        search_path = "SET search_path = #{self.current_tenant}, pg_catalog;"

        sql
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
