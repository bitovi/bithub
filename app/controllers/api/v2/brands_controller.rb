class Api::V2::BrandsController < Api::V2::BaseController
  #before_filter :authenticate_user!, except: [:index, :show]
  respond_to :json

  def index
    @brands = Brand.all

    render :index
  end

  def show
    @brand = Brand.find(params[:id])

    render :show
  end

end
