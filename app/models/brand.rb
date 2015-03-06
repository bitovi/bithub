class Brand < ActiveRecord::Base
  include Traits::AmqpDeclaration

  has_many :identities, class_name: 'BrandIdentity', dependent: :destroy

  scope :identity_from, -> (feed_name) { where(feed_name: feed_name) }

  has_many :embeds, dependent: :destroy
  has_many :services, through: :embeds

  has_and_belongs_to_many :users

  belongs_to :organization

  validates :tenant_name, format: {
    with: /\A[_0-9a-zA-Z]+\z/, message: 'invalid characters'
  }

  after_create  :create_tenant
  after_destroy :destroy_tenant

  after_create  { notify_crawler(:start) }
  after_destroy { notify_crawler(:stop) }

  def self.switch!(name = nil)
    Apartment::Tenant.switch! name
  end

  def create_tenant
    Apartment::Tenant.create tenant_name
    Apartment::Tenant.switch! tenant_name

    # run seed tasks
    Bithub::Application.load_tasks

    # http://stackoverflow.com/questions/577944/how-to-run-rake-tasks-from-within-rake-tasks
    Rake::Task['data:import_or_update_tags'].reenable
    Rake::Task['data:import_or_update_tags'].invoke

    Apartment::Tenant.switch!
  end

  def destroy_tenant
    Apartment::Tenant.drop tenant_name
  end

  def self.find_by_tenant_name(tenant)
    where(tenant_name: tenant).first
  end

  def self.current
    where(tenant_name: Apartment::Tenant.current).first
  end

  def notify_crawler(action)
    unless ENV['RAILS_ENV'] == 'test'
      Rails.logger.info "Publishing a command to crawler #{msg(action)}"
      x('x.crawler').publish((msg(action).to_json), routing_key: :config)
    end
  end

  def msg(action)
    {
      brand: {
        id: id,
        name: name
      },
      signature: "brand_#{action}",
      action: action
    }
  end

end
