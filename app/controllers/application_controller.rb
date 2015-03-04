class ApplicationController < ActionController::Base

  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from ActionView::MissingTemplate, with: :render_404

  def render_404
    render plain: '404 not found', status: 404
  end

  helper_method :crypter

  def crypter
    key = 'some really long key that we will use for this'
    @__crypt ||= ActiveSupport::MessageEncryptor.new(key)
    @__crypt
  end
end
