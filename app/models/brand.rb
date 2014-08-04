class Brand < ActiveRecord::Base

  has_many :accounts, :dependent => :nullify
  has_many :feed_configs, :dependent => :destroy
  has_many :identities, :class_name => 'BrandIdentity', :dependent => :destroy

  has_and_belongs_to_many :users

  validates :tenant_name, format: { with: /\A[-0-9a-zA-Z]+\z/, message: "invalid characters" }

  after_create :create_tenant
  after_save :update_tenant
  after_destroy :destroy_tenant

  private

  def create_tenant
    Apartment::Database.create tenant_name
    Apartment::Database.switch tenant_name

    # run seed tasks
    Bithub::Application.load_tasks

    # http://stackoverflow.com/questions/577944/how-to-run-rake-tasks-from-within-rake-tasks
    Rake::Task['data:import_or_update_tags'].reenable
    Rake::Task['data:import_scoring_rules'].reenable
    Rake::Task['data:import_funnel_definitions'].reenable

    Rake::Task['data:import_or_update_tags'].invoke
    Rake::Task['data:import_scoring_rules'].invoke
    Rake::Task['data:import_funnel_definitions'].invoke

    # repopulate matviews upon creation
    Pagination.refresh
    Leaderboard.refresh
    UserActivity.refresh

    Apartment::Database.switch
  end

  def destroy_tenant
    Apartment::Database.drop tenant_name
  end

  def update_tenant
    rename_tenant if self.changes['tenant_name']
    update_keywords if self.changes['keywords']
  end

  def self.find_by_tenant_name(tenant)
    self.where(tenant_name: tenant).first
  end

  def self.current
    self.where(tenant_name: Apartment::Database.current_tenant).first
  end

  private

  def rename_tenant
    old_name, new_name = self.changes['tenant_name']

    return unless old_name

    sql = "ALTER SCHEMA \"#{old_name}\" RENAME TO \"#{new_name}\""
    ActiveRecord::Base.connection.execute(sql)
  end

  def update_keywords
    old_keywords = self.changes['keywords'].first || []
    new_keywords = self.changes['keywords'].second || []

    # remove old tags from keywords
    old_keywords.each do |k|
      Tag.remove_group k, 'keywords'
    end

    # register new keywords as tags
    new_keywords.each do |k|
      Tag.register k, 'keywords'
    end
  end
end
