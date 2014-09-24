class EmbedEntity < ActiveRecord::Base
  belongs_to :embed
  belongs_to :entity
end

