Bithub::Application.routes.draw do
  devise_for :users

  get 'latest' =>  'home#latest'
  get 'greatest' => 'home#greatest'
  
  resources :events, :except => ['edit', 'new']
  resources :users, :except => ['edit', 'new']
  resources :tags, :except => ['edit', 'new']

  namespace :admin do
    resources :users
    resources :tags
    resources :rules
  end

  root :to => 'home#latest'
end
