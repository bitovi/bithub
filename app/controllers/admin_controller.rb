class AdminController < ApplicationController

  layout false, only: [:index, :embed]
  after_action :allow_iframe, only: :embed

  def index
    unless current_account
      redirect_to :new_account_session
    end
  end

  def embed
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
      response.headers.except! 'X-Frame-Options'
    end

end
