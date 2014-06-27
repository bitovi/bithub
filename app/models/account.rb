class Account < ActiveRecord::Base
  rolify :role_cname => 'AccountRole'

  devise :database_authenticatable, :registerable,
         :rememberable, :trackable, :validatable

  # :token_authenticatable, :confirmable, :recoverable
  # :lockable, :timeoutable, :omniauthable

  belongs_to :brand

  before_create :create_brand

  private

  def create_brand
    brand_name = self.email.split('@').first.gsub(/[^\w-]/,'-')
    self.brand = Brand.new({name: brand_name})
  end

end
