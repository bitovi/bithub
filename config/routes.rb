Bithub::Application.routes.draw do

  devise_for :users,
    controllers: { omniauth_callbacks: "api/auth/omniauth_callbacks" },
    defaults: { format: 'json' }
  
  as :user do 
    get '/api/logout', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

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
      collection do
        get :top
      end
    end

    resources :tags, :except => [:new, :edit] do
      collection do
        get :feeds
        get :categories
        get :projects
      end
    end

    match '/session' => 'session_info#current_session'
    root :to => "application#home"
  end

  namespace :admin do
    resources :users
    resources :events
    resources :tags
    resources :rules
    root :to => "rules#index"
  end

  root :to => "application#home"
end
