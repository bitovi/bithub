class Brand < ActiveRecord::Base

  attr_accessible :name, :display_name, :description, :keywords, :props

  serialize :props, ActiveRecord::Coders::Hstore

  has_many :accounts

  validates :name, format: { with: /\A[-_0-9a-zA-Z]+\z/, message: "invalid characters" }

  after_create :create_tenant
  after_save :update_tenant
  after_destroy :destroy_tenant

  private

  def create_tenant
    Apartment::Database.create(name)
  end

  def destroy_tenant
    Apartment::Database.drop(name)
  end

  def update_tenant
    # update schema name
    if name = self.changes["name"]
      old_name = name.first
      new_name = name.second
      ActiveRecord::Base.connection.execute("ALTER SCHEMA \"#{old_name}\" RENAME TO \"#{new_name}\"")
    end
  end

end
