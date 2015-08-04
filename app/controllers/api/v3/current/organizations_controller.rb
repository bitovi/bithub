class Api::V3::Current::OrganizationsController < Api::V3::Current::AbstractController
  represents_resource Organization

  def choose
    if @organization = current_account.organizations.find_by_id(organization_id)
      AccountOrganization.where(account: current_account, organization: @organization).first.confirm!
      session['organization_id'] = @organization.id
      session['tenant_name']     = @organization.brands.first.tenant_name
      render :show
    else
      render json: { msg: 'You don\'t belong to that organization' }, status: 422
    end
  end

  private
  def resource_params
    params.require(:organization).permit(:name)
  end

  def organization_id
    params[:id]
  end
end
