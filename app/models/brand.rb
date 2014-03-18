class Brand < ActiveRecord::Base

  attr_accessible :name, :display_name, :description, :keywords, :props

  serialize :props, ActiveRecord::Coders::Hstore

  has_many :accounts

  after_create :create_tenant
  after_destroy :destroy_tenant

  private

  def create_tenant
    Apartment::Database.create(name)
  end

  def destroy_tenant
    Apartment::Database.drop(name)
  end

end
