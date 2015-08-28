class Api::V3::EmbedsController < Api::V3::BaseController
  include Api::EmbedScoped

  before_filter :authenticate_account!, except: %i(show)

  def index
    authorize! :index, Embed
    @embeds = Embed.order("created_at DESC").all
  end

  def show
    if current_account
      if (tn = (params[:tenant_name] || Apartment::Tenant.current))
        tn = nil unless Apartment.tenant_names.include?(tn)
        Apartment::Tenant.switch(tn) do
          authorize! :show, owner_embed
          render :show
        end
      end
    else
      render nothing: true, status: 401
    end
  end

  def create
    authorize! :create, built_embed

    @embed.name = generated_name if params[:name].blank?

    if @embed.save
      render :show
    else
      render :json => msg_hash(@embed, 'create'), :status => 422
    end
  end

  def update
    authorize! :update, owner_embed

    if @embed.update_attributes(embed_params)
      render :show
    end
  end

  def destroy
    authorize! :destroy, owner_embed

    if @embed.destroy
      CleanOrphanedEntitiesJob.perform_later

      render :json => msg_hash(@embed, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(@embed, 'destroy'), :status => 406
    end
  end

  def moderate
    authorize! :moderate, owner_embed

    if @embed.moderate
      render :json => msg_hash(@embed, 'moderate')
    else
      render :json => msg_hash(@embed, 'moderate', 'error')
    end
  end

  def publish
    authorize! :update, owner_embed

    if Subscription.current.chargeable?
      @embed.update_attribute :published, true
      render :show
    else
      render :json => msg_hash(@embed, 'publish', 'payment_required'), :status => 402
    end
  end

  def unpublish
    authorize! :update, owner_embed

    if @embed.update_attribute :published, false
      render :show
    end
  end

  private

  def built_embed
    @embed = current_brand.embeds.build(embed_params)
  end

  def embed_params
    params.require(:embed).permit(:name, :colorscheme, :layout, :approved_by_default)
  end

  def generated_name
    Bazaar.heroku
  end

  def embed_id
    params[:id]
  end
end
