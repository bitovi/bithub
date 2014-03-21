class Brand < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :name, :description, :keywords, :props

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

      # skip rest upon creating
      return unless old_name

      sql = "ALTER SCHEMA \"#{old_name}\" RENAME TO \"#{new_name}\""
      ActiveRecord::Base.connection.execute(sql)
    end
  end

end
