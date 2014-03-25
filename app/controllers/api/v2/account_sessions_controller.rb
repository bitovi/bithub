class Api::V2::AccountSessionsController < Devise::SessionsController
  include Api::V2::BaseHelpers

  def create
    super do |resource|
      @account = AccountDecorator.decorate resource
      render 'api/v2/accounts/show.json.jpbuilder'
      break
    end
  end

  def destroy
    super do
      render :json => msg_hash(:account, 'destroy', 'success')
      break
    end
  end

  def failure
    render :json => msg_hash(:account, 'create'), :status => 401
  end

  def auth_options
    super.merge({recall: "#{controller_path}#failure"})
  end

end
