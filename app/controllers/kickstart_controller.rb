class KickstartController < ApplicationController

  layout false, only: [:admin, :embed]
  after_action :allow_iframe, only: :embed

  # Kickstarts the js code that displays the admin app
  def admin
    unless current_account
      redirect_to :new_account_session
    else
      flash[:error] = flash[:errors] = flash[:notice] = nil
      render 'admin'
    end
  end

  # Kickstarts the js code that publicly displays the embed
  def embed
    render 'embed'
  end

  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
