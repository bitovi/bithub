class Api::V3::Current::AccountsController < Api::V3::Current::AbstractController
  represents_resource Account
  
  private
  def resource_params
    params.require(:account).permit(:name)
  end
end
