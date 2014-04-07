class Api::V2::BrandIdentitiesController < Api::V2::BaseController
  #before_filter :authenticate_user!, except: [:index, :show]
  respond_to :json

  def index
    @brand_identities = BrandIdentityDecorator.decorate_collection BrandIdentity.all
    render :index
  end

  def show
    @brand_identity = BrandIdentityDecorator.decorate BrandIdentity.find(params[:id])
    render :show
  end
end
