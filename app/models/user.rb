class User < ActiveRecord::Base
  extend Solipsism

  store_accessor :props

  has_many :ownerships, foreign_key: 'owner_id', :dependent => :destroy
  has_many :entities, through: :ownerships, source: 'entity'

  has_and_belongs_to_many :brands

  scope :only_not_null_names, -> { where("name <> '' and name IS NOT NULL") }
  scope :from_tenant, ->(brand_name) { joins(:brands).where("brands.tenant_name = ?", brand_name) }

  def collect_authored_entities
    identities.each do |ident|
      Entity.origin_author(ident.uid).find_each do |entity|
        entity.author = self
      end
    end
  end

  def collect_hosted_entities
    if (ident = identities.where(provider: 'meetup').first)
      Entity.feed('meetup').type('event').origin_host(ident.uid).find_each do |entity|
        entity.ownerships << Ownership.new(owner: self, entity: entity, ownership_type: :host).determine_value
        entity.save
      end
    end
  end

  def update_blank_attrs(ident)
    self.name = ident.name if self.name.blank? && ident.name.present?
    self.email = ident.email if self.email.blank? && ident.email.present?
  end

  def async_collect_authored_entities
    Workers::UserUpdater.perform_async self.id, :collect_authored_entities
    Workers::UserUpdater.perform_async self.id, :collect_hosted_entities
  end

  def join_brand(brand_name)
    return unless (b = match_brand brand_name)
    brands << b unless brands.include? b
  end

  def remove_brand(brand_name)
    return unless (b = match_brand brand_name)
    brands.delete b
  end

  private

  def match_brand(brand)
    if brand.is_a? Integer
      Brand.find_by_id(brand)
    elsif brand.is_a?(String) || brand.is_a?(Symbol)
      Brand.where(:name => brand.to_s).first
    elsif brand.is_a? Brand
      brand
    end
  end

end
