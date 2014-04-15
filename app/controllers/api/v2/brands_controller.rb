class Api::V2::BrandsController < Api::V2::BaseController
  #before_filter :authenticate_user!, except: [:index, :show]
  respond_to :json

  def index
    @brands = Brand.all

    render :index
  end

  def show
    #@brand = Brand.find(params[:id])
    @brand = Brand.first

    render :show
  end

  def update
    #@brand = Brand.find(params[:id])
    @brand = Brand.first

    if @brand.update_attributes(brand_params)
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
