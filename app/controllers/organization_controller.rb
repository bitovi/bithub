class OrganizationController < ApplicationController

  before_filter :authenticate_account!
  layout 'backend_admin'

  def current
    @organization = current_organization
    render :current
  end

  def edit
    @organization = current_organization
    render :edit
  end

  def update
    @organization = current_organization
    if @organization.update_attributes(update_params)
      redirect_to root_organization_path
    else
      flash[:error] = "Failed to update organization."
      render :edit
    end
  end

  def update_params
    params.require(:organization).permit(:name)
  end

end
