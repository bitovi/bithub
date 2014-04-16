class Api::V2::BrandsController < Api::V2::BaseController
  #before_filter :authenticate_account!, except: [:index, :show]
  respond_to :json

  def index
    @brands = Brand.all
    render :index
  end

  def show
    if (@brand = Brand.find_by_id(current_account.brand_id))
      render :show
    else
      render :json => msg_hash(@brand, 'update'), :status => 406
    end
  end

  def update
    if (@brand = Brand.find_by_id(current_account.id))
      @brand.update_attributes(brand_params)
      render :show
    else
      render :json => msg_hash(@brand, 'update'), :status => 406
    end
  end

  private

  def brand_params
    params.require(:brand).permit(:name, :description, :keywords)
  end
end
