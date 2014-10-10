require 'rails_helper'

RSpec.describe 'Account registration', type: :request do
  it 'creates the brand if an account is being created without an invite'
  it 'creates only the account if an account is being created through an invite'
end
