class Account < ActiveRecord::Base
  attr_accessor :invite_key

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,
         :confirmable

  rolify :role_cname => 'AccountRole'

  validate :invite_key_must_match, :on => :create

  has_and_belongs_to_many :organizations #, through: :accounts_organizations

  def current_brand
    brands.first
  end

  def invite_key_must_match
    if invite_key != ENV['INVITE_KEY']
      errors.add(:invite_key, "does not match")
    end
  end

  def create_subscription
    # subscription creates Stripe's customer,
    # so call it after the brand itself is successfully cerated
    if @brand.save && !ENV['STRIPE_DISABLE'].to_bool
      @brand.subscription = Subscription.new(plan_id: @plan)
      @brand.save
    end
  end

end
