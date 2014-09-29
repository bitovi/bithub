class HstoreDeserializer
  include ActiveRecord::ConnectionAdapters::PostgreSQLColumn::Cast
  def initialize(str)
    @str = str
  end

  def parse
    string_to_hstore(@str)
  end
end
