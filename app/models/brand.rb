class Brand < ActiveRecord::Base
  has_many :identities, class_name: 'BrandIdentity', dependent: :destroy

  has_one  :subscription
  has_many :payments

  scope :identity_from, -> (feed_name) { where(feed_name: feed_name) }

  has_many :embeds, dependent: :destroy
  has_many :services, through: :embeds

  has_and_belongs_to_many :accounts
  has_and_belongs_to_many :users

  validates :tenant_name, format: {
    with: /\A[-0-9a-zA-Z]+\z/, message: 'invalid characters'
  }

  after_create  :create_tenant
  after_update  :rename_tenant_schema
  after_destroy :destroy_tenant

  after_create  :notify_brand_start
  after_destroy :notify_brand_stop

  def create_tenant
    Apartment::Tenant.create tenant_name
    Apartment::Tenant.switch tenant_name

    # run seed tasks
    Bithub::Application.load_tasks

    # http://stackoverflow.com/questions/577944/how-to-run-rake-tasks-from-within-rake-tasks
    Rake::Task['data:import_or_update_tags'].reenable
    Rake::Task['data:import_or_update_tags'].invoke

    Apartment::Tenant.switch
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

  def notify_brand_start
    notify_embed_action(:start)
  end

  def notify_brand_stop
    notify_embed_action(:stop)
  end

  def notify_embed_action(action)
    Support::CrawlerNotifier.new.notif({
      brand: { id: id, name: name },
      signature: "brand_#{action}",
      action: action
    })
  end

  def rename_tenant_schema
    return if !changes['tenant_name'] || !changes['tenant_name'][0]

    old_name, new_name = changes['tenant_name']
    sql = "ALTER SCHEMA \"#{old_name}\" RENAME TO \"#{new_name}\""
    ActiveRecord::Base.connection.execute(sql)
  end
end
