class Admin::AdminController < ActionController::Base
  layout 'layouts/admin'
  before_filter :authenticate_user!
  load_and_authorize_resource
end
