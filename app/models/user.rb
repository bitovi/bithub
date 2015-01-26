class User < ActiveRecord::Base
  extend Solipsism

  store_accessor :props

  has_many :ownerships, foreign_key: 'owner_id', :dependent => :destroy
  has_many :entities, through: :ownerships, source: 'entity'

  has_and_belongs_to_many :brands

  scope :only_not_null_names, -> { where("name <> '' and name IS NOT NULL") }
  scope :from_tenant, ->(brand_name) { joins(:brands).where("brands.tenant_name = ?", brand_name) }

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
