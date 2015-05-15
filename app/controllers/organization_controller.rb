class OrganizationController < ApplicationController

  before_filter :authenticate_account!
  layout 'backend_admin'

end
