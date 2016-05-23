class BrandsController < ApplicationController

  before_filter :authenticate_user!
  layout 'backend_admin'

end
