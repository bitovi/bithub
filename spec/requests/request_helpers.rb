def post_headers
  {
    'CONTENT_TYPE' => 'application/json'
  }
end

def account_registration_data
  {
    name: 'neektza',
    email: 'neektza@gmail.com',
    password: 'foobar123',
    password_confirmation: 'foobar123'
  }
end

def account_login_data
  {
    name: 'neektza',
    password: 'foobar123',
    remember_me: '0'
  }
end

def brand_data
  {
   name: 'brand new Brand',
   tenant_name: 'brandnewbrand'
  }
end
