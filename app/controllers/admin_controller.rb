class AdminController < ApplicationController

  layout false, only: [:index, :embed]
  after_action :allow_iframe, only: :embed

  def index
    unless current_account
      redirect_to :new_account_session
    else
      flash[:error] = flash[:errors] = flash[:notice] = nil
    end
  end

  def embed
    if brand = Brand.where(tenant_name: params[:tenant]).first
      Apartment::Tenant.switch(brand.name) do
        if embed = Embed.find_by_id(params[:hubId])
          if embed.published
            @embed_is_public = true
          end
        end
      end
    end
  end

  def choose_brand
    if current_account
      if tenant_name = params['tenant_name']
        session['tenant_name'] = tenant_name
        redirect_to :admin_index
      else
        @brands = current_account.brands
        render 'admin/choose_brand', layout: 'admin'
      end
    else
      redirect_to :new_account_session
    end
  end

  private

    def allow_iframe
      response.headers.except! 'X-Frame-Options' if @embed_is_public
      
    end

end
