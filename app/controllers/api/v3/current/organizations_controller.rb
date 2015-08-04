class Api::V3::Current::OrganizationsController < Api::V3::Current::AbstractController
  represents_resource Organization

  private
  def resource_params
    params.require(:organization).permit(:name)
  end
end
