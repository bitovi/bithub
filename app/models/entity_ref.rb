class EntityRef < ActiveRecord::Base
  belongs_to :source, foreign_key: "from_id", class_name: "Entity"
  belongs_to :target, foreign_key: "to_id", class_name: "Entity"

  validates_uniqueness_of :from_id, scope: :to_id
  validates_uniqueness_of :to_id, scope: :from_id

  def self.create_reference(opts)
    opts.symbolize_keys!

    ref = self.new

    ref.from_id = opts[:from_id]
    ref.to_id   = opts[:to_id]

    ref.save
  end

end
