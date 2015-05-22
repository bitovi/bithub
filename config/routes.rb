require 'sidekiq/web'

Bithub::Application.routes.draw do

  get '/admin', to: 'kickstart#admin'
  get '/embed', to: 'kickstart#embed'

  resources :accounts, only: %i(index)

  resource :organization, only: %i(edit update), to: 'organization' do
    root to: 'organization#current'

    resources :accounts, only: %i(index destroy), to: 'organization_accounts'
    resources :invitations, only: %i(index new create update destroy), to: 'organization_invitations'

    get 'choices', to: 'organization_accounts#choices'
    post 'choose', to: 'organization_accounts#choose'
  end

  resource :brand, only: %i(show edit update) do
    get 'choices', to: 'brand_accounts#choices'
    post 'choose', to: 'brand_accounts#choose'
  end

  resources :subscriptions, only: %i(show) do
    collection do
      get 'current', to: 'subscriptions#current'
      get 'edit/plan', to: 'subscriptions#edit_plan'
      get 'edit/cc',   to: 'subscriptions#edit_cc'
      post 'update',   to: 'subscriptions#update'
    end
  end

  # Devise
  devise_for :accounts,
    controllers: {
      sessions: 'auth/sessions',
      registrations: 'auth/registrations',
      confirmations: 'auth/confirmations',
      invitations: 'auth/invitations',
      omniauth_callbacks: 'auth/omniauth_callbacks'
    }

  as :account do
    get '/account', to: redirect('/accounts/edit')

    get '/register/:plan', to: redirect { |path_params, req| "/accounts/sign_up?plan=#{path_params[:plan]}" }
    get '/register', to: redirect('/accounts/sign_up')
    get '/login', to: redirect('/accounts/sign_in')
    get '/logout', to: redirect('/accounts/sign_out')
    
    get '/accounts/login', to: redirect('/accounts/sign_in')
    get '/accounts/logout', to: redirect('/accounts/sign_out')
    get '/accounts/register', to: redirect('/accounts/sign_up')
  end

  # Stripe
  mount Stripe::Engine => "/stripe"

  # SERVICE API Routes
  namespace :api, defaults: { format: 'json' } do

    namespace :v3 do
      resources :embeds, except: %i(new edit) do
        post :moderate, on: :member

        resources :entities, to: 'embed_entities', only: %i(index show destroy) do
          put :approve, on: :member
          put :disapprove, on: :member
          put :block, on: :member
          put :pin, on: :member
          put :unpin, on: :member
          get :approved, on: :collection
          get :waitlisted, on: :collection
        end

        resources :filters, except: %i(new edit)
        resources :services, except: %i(new edit update)
      end

      resources :presets, to: 'embed_presets', except: %i(new edit)

      resources :services, except: %i(new edit) do
        get 'tree', on: :collection
        get 'suggestions/:feed_name', on: :collection, to: 'services#suggestions'
        get 'suggestions/:feed_name/:feed_type', on: :collection, to: 'services#suggestions'
      end

      resources :brands,  except: %i(new edit) do
        collection do
          get 'current', to: 'brands#show'
          put 'current', to: 'brands#update'
          get 'current/payments', to: 'payments#index'
          get 'current/identities/:provider', to: 'brand_identities#index'
          get 'current/identities', to: 'brand_identities#index'
          get 'current/identities/:id', to: 'brand_identities#show'
          delete 'current/identities/:id', to: 'brand_identities#destroy'
        end
      end

      resources :accounts, only: %i() do
        collection do
          get 'current', to: 'accounts#current'
        end
      end

      get 'analytics/:source_type', to: 'analytics#show'

      resources :brand_identities, path: 'identities', only: %i(index show destroy)
      resources :services, except: %i(new edit update)
      resources :subscriptions, only: %i(show) do
        collection do
          get 'current', to: 'subscriptions#current'
        end
      end
      resources :filters, except: %i(new edit)
      resources :tags, except: %i(new edit)
      resources :plans, only: %i(show index)
    end
  end

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end unless Rails.env.development?
  mount Sidekiq::Web => '/sidekiq'

  get '/:page', to: 'static_pages#render_page'
  root 'static_pages#index'


  match '*path', via: :all, to: 'application#render_404'
end
