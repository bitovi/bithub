class Api::V2::BrandIdentitiesController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    identities = is_admin? ? BrandIdentity.all : current_account.brand.identities

    @brand_identities = BrandIdentityDecorator.decorate_collection identities
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
