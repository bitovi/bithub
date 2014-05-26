class Funnel < ActiveRecord::Base
  attr_accessible :name, :display_name, :feed_name, :type_name, :tags

  def as_query
    {
      :tagged_with => tags,
      :where => {
        :type_name => type_name,
        :feed_name => feed_name
      }
    }
  end
end
