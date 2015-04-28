class Api::V3::BrandIdentitiesController < Api::V3::BaseController
  before_filter :authenticate_account!

  def index
    @identities = provider ? my_identities.where(provider: provider) : my_identities
    @identities = [] unless @identities

    authorize! :read, @identities
    render :index
  end

  def show
    @identity = my_identities.find(params[:id])
    authorize! :read, @identity

    if @identity
      render :show
    else
      render :json => msg_hash(@identity, 'show'), status: 406
    end
  end

  def destroy
    @identity = my_identities.find(params[:id])
    authorize! :destroy, @identity

    if @identity.destroy
      render :json => msg_hash(@identity, 'destroy', 'success')
    else
      render :json => msg_hash(@identity, 'destroy'), :status => 406
    end
  end

  private
  def provider
    params[:provider]
  end

  def my_identities
    current_brand.identities
  end

end
