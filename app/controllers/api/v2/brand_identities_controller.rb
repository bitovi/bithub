class Api::V2::BrandIdentitiesController < Api::V2::BaseController
  #before_filter :authenticate_user!, except: [:index, :show]
  respond_to :json

  def index
    @brand_identities = BrandIdentityDecorator.decorate_collection BrandIdentity.all
    render :index
  end

  def show
    if (bi = current_account.brand.identities.find_by_id(params[:id]))
      @brand_identity = BrandIdentityDecorator.decorate bi
      render :show
    else
      render :json => msg_hash(@brand_identity, 'show'), :status => 406
    end
  end
end
