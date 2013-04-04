Bithub::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  namespace :api, :defaults => { :format => 'json' } do

    # (CRUD) /api/events
    # GET /api/events/:event_id/activities - all activities on an event
    # POST /api/events/:event_id/(upvotes|award|anteup) - activity creation
    resources :events, :except => [:new, :edit] do
      resources 'activities', :only => :index, :to => 'event_activities#index'
      resources 'upvotes', :only => :create, :to => 'event_activities#create_upvote'
      resource 'award', :only => :create, :to => 'event_activities#create_award'
      resource 'anteup', :only => :create, :to => 'event_activities#create_anteup'
    end

    # (RUD) /api/users
    # GET /api/users/:user_id/activities - user's 'awards'
    # GET /api/users/:user_id/events - user's authored events
    resources :users, :except => [:new, :edit] do
      resources 'activities', :only => :index, :to => 'users#activities'
      resources 'events', :only => :index, :to => 'users#events'
      collection do
        get :top
      end
    end

    # /api/tags
    # /api/tags/feeds
    # /api/tags/categories
    resources :tags, :except => [:new, :edit] do
      collection do
        get :feeds
        get :categories
        get :projects
      end
    end
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
