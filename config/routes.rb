Bithub::Application.routes.draw do

  as :user do 
    get '/api/auth/logout', :to => 'devise/sessions#destroy', :as => :destroy_user_session
    get '/admin/logout', :to => 'devise/sessions#destroy', :as => :admin_logout
  end

  devise_for :users,
    controllers: { omniauth_callbacks: "api/auth/omniauth_callbacks" },
    defaults: { format: 'json' }

  namespace :api, :defaults => { :format => 'json' } do
    resources :events, :except => [:new, :edit] do
      resources 'activities', :only => :index, :to => 'event_activities#index'
      resources 'upvote', :only => :create, :to => 'event_activities#create_upvote'
      resource 'award', :only => :create, :to => 'event_activities#create_award'
      resource 'anteup', :only => :create, :to => 'event_activities#create_anteup'
    end

    resources :users, :except => [:new, :edit] do
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

    match '/session' => 'session_info#current_session'
    root :to => "api#home"
  end

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
