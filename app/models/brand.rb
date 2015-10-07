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

  scope :active, -> { where(is_active: true) }
  scope :with_card, -> { joins(:subscription).where("subscriptions.card_last4 IS NOT NULL") }

  scope :inactive, -> { where(is_active: false) }
  scope :without_card, -> { joins(:subscription).where("subscriptions.card_last4 IS NULL") }

  after_create  :create_tenant
  after_destroy :destroy_tenant

  after_create  { notify_crawler(:start) }
  after_destroy { notify_crawler(:stop) }

  # Fetch Brands that have at least one Embed and a Service connected
  
  def self.switch!(name = nil)
    Apartment::Tenant.switch! name
  end

  def self.current
    where(tenant_name: Apartment::Tenant.current).first
  end

  def self.flag_inactive
    ActiveRecord::Base.connection.execute <<-SQL
      BEGIN;
      UPDATE brands SET is_active = 't';

      UPDATE brands SET is_active = 'f'
      FROM (
          SELECT
            organizations. ID,
            COUNT (confirmed_at) AS confirmed_accounts,
            MAX (accounts.last_sign_in_at) AS last_sign_in_at
          FROM
            accounts,
            account_organizations,
            organizations
          WHERE
            accounts.id = account_organizations.account_id
          AND organizations.id = account_organizations.organization_id
          GROUP BY
            organizations.id
        ) AS org_data
      WHERE
        org_data.id = brands.organization_id
      AND org_data.last_sign_in_at < now() :: TIMESTAMP - '1 week' :: INTERVAL
      AND org_data.confirmed_accounts = 0;

      COMMIT;
    SQL
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
