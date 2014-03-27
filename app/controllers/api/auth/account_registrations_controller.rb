class Api::Auth::AccountRegistrationsController < Devise::RegistrationsController
  include Api::V2::BaseHelpers

  # source code:
  # http://github.com/plataformatec/devise/blob/master/app/controllers/devise/registrations_controller.rb

  def create
    super do |resource|
      account = resource

      brand_name = account.email.split('@').first.gsub(/[^\w-]/,'-')
      account.brand = Brand.new({name: brand_name})

      if account.save
        sign_up(resource_name, account)
        @account = AccountDecorator.decorate account
        render 'api/v2/accounts/show', :formats => [:json]
      else
        clean_up_passwords account
        render :json => msg_hash(account, 'create'), :status => 406
      end

      break
    end
  end

  def destroy
    super do |resource|
      @account = AccountDecorator.decorate resource
      render 'api/v2/accounts/show', :formats => [:json]
      break
    end
  end

  # Updating is done via accounts_controller#update(_password)
  #
  # def update
  #   super do |resource|
  #     if update_resource(resource, account_update_params)
  #       sign_in resource_name, resource, bypass: true
  #       @account = AccountDecorator.decorate resource
  #       render 'api/v2/accounts/show.json.jpbuilder'
  #     else
  #       clean_up_passwords resource
  #       render :json => msg_hash(resource, 'update'), :status => 406
  #     end

  #     break
  #   end
  # end

end
