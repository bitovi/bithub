class EventMongo
  include Mongoid::Document
  store_in collection: 'events'

  field :hash_key
  field :source_id        # origin_id
  field :title
  field :body
  field :link             # url
  field :feed
  field :type
  field :category
  field :actor            # origin_author_username
  field :actor_id         # origin_author_id
  field :actor_gravatar   # origin_author_gravatar_hash
  field :source_data
  field :created_ts       # origin_ts
  field :votes            # total nmb of upvotes
  field :points           # authorship_value
  field :state            # open/closed
end

