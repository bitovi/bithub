class Api::V2::BaseController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401

  respond_to :json

  include Api::V2::BaseHelpers

  def home
    render :text => "Bithub API v2"
  end

  # CanCan override:
  # https://github.com/ryanb/cancan/wiki/changing-defaults
  def current_ability
    if account_signed_in?
      @current_ability ||= AccountAbility.new current_account
    else
      @current_ability ||= AnonAbility.new
    end
  end

  # Handle mutiple devise models for auth
  def authenticate!
    if account_signed_in?
      :authenticate_account!
    end
  end

end
