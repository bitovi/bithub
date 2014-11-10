class AdminController < ApplicationController

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

end
