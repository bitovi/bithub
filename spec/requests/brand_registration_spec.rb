require 'rails_helper'

RSpec.describe 'Account registration', type: :request do
  it 'creates an account, a default embed and a template for a service'
  it 'creates the brand along with the account if account is being registered'
  it 'doesn\'t create the brand if the account is being invited'
end
