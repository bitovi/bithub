class Api::V2::BrandsController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    @brands = Brand.all
    render :index
  end

  def show
    if (@brand = current_account.brand)
      render :show
    else
      render :json => msg_hash(@brand, 'update'), :status => 406
    end
  end

  def update
    if (@brand = current_account.brand)
      @brand.update_attributes(brand_params)
      render :show
    else
      render :json => msg_hash(@brand, 'update'), :status => 406
    end
  end

  private

  def brand_params
    unless brand = params.andand[:brand]
      params[:brand] = {}
    end
    unless keywords = brand.andand[:keywords]
      params[:brand][:keywords] = []
    end

    params.require(:brand).permit(:description, :keywords => [])
  end
end
