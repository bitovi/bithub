class EmbedEvent < ActiveRecord::Base

  validates_presence_of :brand_id, :embed_id

  belongs_to :organization
  belongs_to :brand
  belongs_to :embed

  def self.log_attr_update!(embed, attr)
    brand = Brand.current
    org   = brand.organization

    ee = EmbedEvent.new\
      organization_id: org.id,
      brand_id: brand.id,
      embed_id: embed.id,
      organization_name: org.name,
      brand_name: brand.name,
      embed_name: embed.name,
      action: 'update',
      attr: attr,
      old_value: embed.attribute_was(attr),
      new_value: embed[attr]

    ee.save!
  end

  def self.log_destroy!(embed)
    brand = Brand.current
    org   = brand.organization

    ee = EmbedEvent.new\
      organization_id: org.id,
      brand_id: brand.id,
      embed_id: embed.id,
      organization_name: org.name,
      brand_name: brand.name,
      embed_name: embed.name,
      action: 'destroy'

    ee.save!
  end

  def self.export_for_monthly_billing_by_org_id(organization_id, opts={})
    _year  = opts.fetch(:year) { Time.now.year }
    _month = opts.fetch(:month) { Time.now.month }

    month = Time.new _year, _month

    EmbedEvent\
      .where(organization_id: organization_id)
      .where(created_at: month.beginning_of_month..month.end_of_month)
      .order(created_at: :asc)
      .map do |ee|
        MonthlyBillings::Record.new\
          ee.organization_id,
          ee.brand_id,
          ee.embed_id,
          ee.organization_name,
          ee.brand_name,
          ee.embed_name,
          ee.active?,
          ee.created_at.to_datetime
      end
  end

  def active?
    if is_publish?
      true
    elsif is_unpublish?
      false
    else
      nil
    end
  end

  def is_publish?
    action == 'update' && attr == 'published' && new_value == 't'
  end

  def is_unpublish?
    action == 'destroy' || (action == 'update' && attr == 'published' && new_value == 'f')
  end

end
