class Brand < ActiveRecord::Base
  include RabbitHelper::Sugar

  has_many :identities, class_name: 'BrandIdentity', dependent: :destroy

  has_many :embeds, dependent: :destroy
  has_many :services, through: :embeds

  has_and_belongs_to_many :users

  belongs_to :organization
  has_one :subscription, through: :organization

  validates :tenant_name, format: {
    with: /\A[_0-9a-zA-Z]+\z/, message: 'invalid characters'
  }

  after_create  :create_tenant
  after_destroy :destroy_tenant

  after_create  { notify_crawler(:start) }
  after_destroy { notify_crawler(:stop) }

  # Fetch Brands that have at least one Embed and a Service connected
  
  def self.with_card
    joins(:subscription).where("subscriptions.card_last4 IS NOT NULL")
  end

  def self.without_card
    joins(:subscription).where("subscriptions.card_last4 IS NULL")
  end

  def self.active
    where(:is_active => true)
    # non_empty_brand_ids = pluck(:tenant_name).map do |tenant_name|
    #   Apartment::Tenant.switch(tenant_name) do
    #     Service.joins(:embed).select("services.*, embeds.brand_id").uniq.pluck(:brand_id)
    #   end
    # end.flatten.uniq
    
    # where(:id => non_empty_brand_ids)
  end

  def self.switch!(name = nil)
    Apartment::Tenant.switch! name
  end

  def self.current
    where(tenant_name: Apartment::Tenant.current).first
  end

  def has_connected_brand_idents?(provider_name)
    identities_from(provider_name).count > 0
  end
  
  def identities_from(provider_name)
    identities.where(provider: provider_name)
  end

  def create_tenant
    Apartment::Tenant.create tenant_name
    Apartment::Tenant.switch! tenant_name

    Apartment::Tenant.switch!
  end

  def destroy_tenant
    Apartment::Tenant.drop tenant_name
  end

  def self.find_by_tenant_name(tenant)
    where(tenant_name: tenant).first
  end

  def notify_crawler(action)
    unless ENV['RAILS_ENV'] == 'test'
      Rails.logger.info "Publishing a command to crawler #{msg(action)}"
      x('x.crawler', chan_is_short_lived = true) do |xchange|
        xchange.publish((msg(action).to_json), routing_key: :config)
      end
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
