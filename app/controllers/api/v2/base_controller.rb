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
      # Brand manager
      @current_ability ||= AccountAbility.new current_account
    elsif user_signed_in?
      # Regular user
      @current_ability ||= UserAbility.new current_user
    else
      # Anonymous
      @current_ability ||= AnonAbility.new
    end
  end

end
