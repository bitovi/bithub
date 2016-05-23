class HubEvent < ActiveRecord::Base

  validates_presence_of :brand_id, :hub_id

  belongs_to :organization
  belongs_to :brand
  belongs_to :hub

  def self.log_attr_update!(hub, attr)
    brand = Brand.current
    org   = brand.organization

    ee = HubEvent.new\
      organization_id: org.id,
      brand_id: brand.id,
      hub_id: hub.id,
      organization_name: org.name,
      brand_name: brand.name,
      hub_name: hub.name,
      action: 'update',
      attr: attr,
      old_value: hub.attribute_was(attr),
      new_value: hub[attr]

    ee.save!
  end

  def self.log_destroy!(hub)
    brand = Brand.current
    org   = brand.organization

    ee = HubEvent.new\
      organization_id: org.id,
      brand_id: brand.id,
      hub_id: hub.id,
      organization_name: org.name,
      brand_name: brand.name,
      hub_name: hub.name,
      action: 'destroy'

    ee.save!
  end

  def self.export_for_monthly_billing_by_org_id(organization_id, opts={})
    _year  = opts.fetch(:year) { Time.now.year }
    _month = opts.fetch(:month) { Time.now.month }

    month = Time.new _year, _month

    already_seen_hubs = []

    HubEvent\
      .where(organization_id: organization_id)
      .order(created_at: :desc)
      .reduce([]) do |acc, ee|
        mbr = MonthlyBillings::Record.new\
          ee.organization_id,
          ee.brand_id,
          ee.hub_id,
          ee.organization_name,
          ee.brand_name,
          ee.hub_name,
          ee.active?

        # create record if the log is within current month,
        # in a case that there is 'activating' log in past,
        # that doesn't reoccure in current month,
        # add it to beginning of the month to trigger billing
        if ee.created_at > month.beginning_of_month && ee.created_at < month.end_of_month
          already_seen_hubs.push ee.id
          mbr.date = ee.created_at.to_datetime
          acc.unshift mbr
        elsif ee.created_at < month.beginning_of_month && ee.active? && !already_seen_hubs.include?(ee.id)
          mbr.date = month.beginning_of_month
          acc.unshift mbr
        end

      acc
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
