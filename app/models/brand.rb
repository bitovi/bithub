class Brand < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :name, :description, :keywords, :props

  serialize :props, ActiveRecord::Coders::Hstore.new({})

  has_many :accounts
  has_many :feed_configs
  has_many :identities, :class_name => 'BrandIdentity'

  validates :name, format: { with: /\A[-_0-9a-zA-Z]+\z/, message: "invalid characters" }

  after_create :create_tenant
  after_save :update_tenant
  after_destroy :destroy_tenant

  private

  def create_tenant
    Apartment::Database.create(name)
    Apartment::Database.switch name

    # run seed tasks
    Bithub::Application.load_tasks

    # http://stackoverflow.com/questions/577944/how-to-run-rake-tasks-from-within-rake-tasks
    Rake::Task['data:import_or_update_tags'].reenable
    Rake::Task['data:import_category_determination_rules'].reenable
    Rake::Task['data:import_scoring_rules'].reenable

    Rake::Task['data:import_or_update_tags'].invoke
    Rake::Task['data:import_category_determination_rules'].invoke
    Rake::Task['data:import_scoring_rules'].invoke

    # repopulate matviews upon creation
    Pagination.refresh
    Leaderboard.refresh
    UserActivity.refresh

    Apartment::Database.switch
  end

  def destroy_tenant
    Apartment::Database.drop(name)
  end

  def update_tenant
    rename_tenant if self.changes['name']
    update_keywords if self.changes['keywords']
  end

  private

  def rename_tenant
    old_name, new_name = self.changes['name']

    Tag.register new_name, 'keywords'

    return unless old_name

    Tag.remove_group old_name, 'keywords'

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
