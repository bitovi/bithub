class Api::V3::BrandIdentitiesController < Api::V3::BaseController
  before_filter :authenticate_account!

  before_action :set_identity, only: %i(show destroy)

  def index
    authorize! :index, BrandIdentity
    @identities = provider ? my_identities.where(provider: provider) : my_identities
    render :index
  end

  def show
    authorize! :show, @identity
    render :show
  end

  def destroy
    authorize! :destroy, @identity

    if @identity.destroy
      render :json => msg_hash(@identity, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(@identity, 'destroy'), :status => 406
    end
  end

  private
  def provider
    params[:provider]
  end

  def set_identity
    @identity = my_identities.find(params[:id])
  end

  def my_identities
    current_brand.identities
  end
end
