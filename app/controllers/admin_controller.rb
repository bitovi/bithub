class AdminController < ApplicationController

  layout false, only: [:index, :hub]
  after_action :allow_iframe, only: :hub

  def index
    unless current_user
      redirect_to :new_user_session
    else
      flash[:error] = flash[:errors] = flash[:notice] = nil
    end
  end

  def hub
    if brand = Brand.where(tenant_name: params[:tenant]).first
      Apartment::Tenant.switch(brand.name) do
        if hub = Hub.find_by_id(params[:hubId])
          if hub.published
            @hub_is_public = true
          end
        end
      end
    end
  end

  def choose_brand
    if current_user
      if tenant_name = params['tenant_name']
        session['tenant_name'] = tenant_name
        redirect_to :admin_index
      else
        @brands = current_user.brands
        render 'admin/choose_brand', layout: 'admin'
      end
    else
      redirect_to :new_user_session
    end
  end

  private

    def allow_iframe
      response.headers.except! 'X-Frame-Options' if @hub_is_public
      
    end

end
