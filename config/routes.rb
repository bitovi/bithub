Bithub::Application.routes.draw do
  
  devise_for :users,
    controllers: { omniauth_callbacks: "api/auth/omniauth_callbacks" }
  
  as :user do 
    get '/api/auth/logout', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  namespace :api, :defaults => { :format => 'json' } do
    match '/auth/session' => 'session_info#current_session'

    resources :events, :except => [:new, :edit] do
      resources 'activities', :only => :index, :to => 'event_activities#index'
      resources 'upvote', :only => :create, :to => 'event_activities#create_upvote'
      resource 'award', :only => :create, :to => 'event_activities#create_award'
      resource 'anteup', :only => :create, :to => 'event_activities#create_anteup'
      get :image, :on => :member
    end

    resources :users, :except => [:new] do
      resources 'activities', :only => :index, :to => 'users#activities'
      resources 'events', :only => :index, :to => 'users#events'
    end

    resources :tags, :except => [:new, :edit] do
      collection do
        get :feeds
        get :categories
        get :projects
      end
    end

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
