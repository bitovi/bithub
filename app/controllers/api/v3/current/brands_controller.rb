class Api::V3::Current::BrandsController < Api::V3::Current::AbstractController
  represents_resource Brand

  private
  def resource_params
    params.require(:brand).permit(:name)
  end
end
