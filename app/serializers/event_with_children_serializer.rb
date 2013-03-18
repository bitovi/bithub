class EventWithChildrenSerializer < ActiveModel::Serializer
  attributes :id, :title, :body
  has_many :children, :serializer => ChildSerializer
  has_many :activities, :serializer => ActivitySerializer
  has_many :tags, :embed => :ids, :embed_key => :name, :root => :tags
end
