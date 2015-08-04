class Api::V3::Current::AbstractController < Api::V3::BaseController
  before_filter :authenticate_account!
  before_action :set_current_resource, only: %i(show update destroy)

  def self.represents_resource(klass)
    @klass = klass
  end

  def self.represented_resource
    @klass
  end

  def show
    authorize! :show, @resource
  end

  def update
    authorize! :update, @resource

    @resource.update_attributes(resource_params)
    render json: @resource, status: (@resource.valid? ? :ok : :not_acceptable )
  end
  
  def destroy
    authorize! :destroy, @resource
    @resource.destroy
    render json: @resource, status: (@resource.valid? ? :ok : :not_acceptable )
  end

  private

  def chain_start
    self.class.represented_resource
  end

  def set_current_resource
    resource_name = self.class.represented_resource.to_s.downcase
    instance_variable_set("@#{resource_name}", @resource = send("current_#{resource_name}"))
  end

  def resource_params
    # Implement this in subclass
  end
end
