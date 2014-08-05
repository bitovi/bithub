class BrandsUser < ActiveRecord::Base

  store_accessor :props

  def self.find_by_user_and_brand(user_id, brand_id)
    self.where(:user_id => user_id, :brand_id => brand_id).first
  end

  def self.find_by_user(user_id)
    if brand = Brand.current
      self.find_by_user_and_brand(user_id, brand.id)
    end
  end

end
