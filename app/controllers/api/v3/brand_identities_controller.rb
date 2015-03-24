class Api::V3::BrandIdentitiesController < Api::V3::BaseController
  before_filter :authenticate_account!
  load_and_authorize_resource

  def index
    if provider
      @identities = current_brand.identities.where(provider: provider) || []
    else
      @identities = current_brand.identities || []
    end
    render :index
  end

  def show
    if @identity = current_brand.identities.find(params[:id])
      render :show
    else
      render :json => msg_hash(@identity, 'show'), status: 406
    end
  end

  def destroy
    @bi = current_brand.identities.find(params[:id])

    if @bi.destroy
      render :json => msg_hash(@bi, 'destroy', 'success')
    else
      render :json => msg_hash(@bi, 'destroy'), :status => 406
    end
  end

  private
  def provider
    params[:provider]
  end

end
