class Api::V3::CredentialsController < Api::V3::ApiController
  before_action :set_credential, only: %i(show destroy)

  def index
    authorize! :index, Credential
    @identities = provider ? my_credentials.where(provider: provider) : my_credentials
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

  def set_credential
    @identity = my_credentials.find(params[:id])
  end

  def my_credentials
    current_brand.identities
  end
end
