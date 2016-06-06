# Added this model so that we could ensure that apartment does
# not attempt to remove brands_users table from each tenant.
# You can only do this by specifying an excluded model.
class BrandsUser < ActiveRecord::Base
end