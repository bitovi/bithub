Bithub::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  namespace :api, :defaults => { :format => 'json' } do
    resources :events, :except => ['edit', 'new'] do
      get 'activities', :on => :member
    end

    resources :users, :except => ['edit', 'new'] do
      get 'activities', :on => :member
    end

    resources :tags, :except => ['edit', 'new']
  end
    
  namespace :admin do
    resources :users
    resources :tags
    resources :rules
  end

end
