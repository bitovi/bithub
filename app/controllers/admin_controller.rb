class AdminController < ApplicationController

  def choose_brand
    render 'admin/choose_brand', layout: 'devise'
  end

end
