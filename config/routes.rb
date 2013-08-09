Bithub::Application.routes.draw do
  
  devise_for :users,
    controllers: { omniauth_callbacks: "api/auth/omniauth_callbacks" }
  
  as :user do 
    get '/api/auth/logout', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  namespace :api, :defaults => { :format => 'json' } do
    match '/auth/session' => 'auth/session_info#current_session'

    resources :events, :except => [:new, :edit] do
      resources 'activities', :only => :index, :to => 'event_activities#index'
      resources 'upvote', :only => :create, :to => 'event_activities#create_upvote'
      resource 'award', :only => :create, :to => 'event_activities#create_award'
      resource 'anteup', :only => :create, :to => 'event_activities#create_anteup'
      get :summary, :on => :collection
    end

    resources :users, :except => [:new] do
      resources 'activities', :only => :index, :to => 'user_activities#index'
      resources 'events', :only => :index, :to => 'user_events#index'
      member do
        get 'add_role', :to => 'users#add_role'
        get 'remove_role', :to => 'users#remove_role'
      end
      collection do
        get 'twitter', :to => 'users#from_twitter'
        get 'github', :to => 'users#from_github'
      end
    end

    resources :tags, :except => [:new, :edit] do
      collection do
        get :feeds, :to => 'tags#index'
        get :categories, :to => 'tags#index'
        get :projects, :to => 'tags#index'
      end
    end
    
    resources :rewards
    resources :countries, :only => :index

    root :to => "api#home"
  end

  # NEEDS TO BE BELOW ALL API ROUTES !!!
  namespace :admin do
    resources :users do
      resources :activities, only: [:destroy]
    end
    resources :events
    resources :tags
    resources :rules
    resources :countries
    root :to => "rules#index"
  end

  root :to => "api#home"
end
