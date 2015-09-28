class Api::V3::InteractionsController < Api::V3::ApiController
  respond_to :html

  skip_before_action :require_account!, only: %w(create)

  def index
    @zoom = zoom
    @data = Interaction.stats(resolution, zoom, composed_filter).all
    render :index
  ensure
    Apartment::Tenant.switch!
  end

  def create
    Apartment::Tenant.switch(tenant_name) do
      @interaction = Interaction.create(interaction_params)
    end
    render json: @interaction
  rescue ArgumentError => e
    show_406(e.message)
  ensure
    Apartment::Tenant.switch!
  end

  def destroy
    @interaction.destroy
    render json: @interaction
  end

  private

  def interaction_params
    params.require(:interaction).permit(
      :primary_source_id,
      :primary_source_type,
      :secondary_source_id,
      :secondary_source_type,
      :event_type,
      :event_subtype,
      :created_at,
      :tenant_name
    )
  end

  def interaction_type
    params.permit(:type)
  end

  private

  def switch_tenant
  end

  def tenant_name
    @tenant_name = session[:tenant_name] || params[:interaction][:tenant_name]
    fail ArgumentError.new('Tenant must be known.') unless @tenant_name
    params[:interaction].delete(:tenant_name) if params[:interaction]
    @tenant_name
  end
  
  def resolution
    params['resolution'] || 'hour'
  end

  def composed_filter
    attrs = %i(primary_source_id secondary_source_id primary_source_type secondary_source_type event_type event_subtype)

    Hash[attrs.select do |a|
      params[a].present?
    end.map do |a|
      [a, params[a]]
    end]
  end

  def zoom
    params[:zoom] || 'detailed'
  end

  def set_zoom
    @zoom = zoom
  end
end
