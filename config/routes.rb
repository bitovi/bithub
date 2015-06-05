require 'sidekiq/web'

Bithub::Application.routes.draw do


  # Frontend
  root 'frontend#index'

  get 'embed', to: 'admin#embed'

  # Admin
  resources :admin, only: %i(index) do
    collection do
      get 'embed', to: 'admin#embed'
      get 'choose_brand', to: 'admin#choose_brand'

      resources :subscriptions, only: %i() do
        collection do
          # get 'edit/plan', to: 'subscriptions#edit_plan'
          get 'edit/cc',   to: 'subscriptions#edit_cc'
          post 'update',   to: 'subscriptions#update'
        end
      end
    end
  end

  # Devise
  devise_for :accounts,
    controllers: {
      sessions: 'auth/sessions',
      registrations: 'auth/registrations',
      confirmations: 'auth/confirmations',
      omniauth_callbacks: 'auth/omniauth_callbacks'
    }

  as :account do
    # get '/register/:plan', to: redirect { |path_params, req| "/accounts/sign_up?plan=#{path_params[:plan]}" }
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
        put :publish, on: :member
        put :unpublish, on: :member

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
          # get 'current/payments', to: 'payments#index'
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

      get 'analytics', to: 'analytics#show'
      get 'interactions', to: 'interactions#index'

      resources :brand_identities, path: 'identities', only: %i(index show destroy)
      resources :services, except: %i(new edit update)
      resources :subscriptions, only: %i(show) do
        collection do
          get 'current', to: 'subscriptions#current'
        end
      end
      resources :filters, except: %i(new edit)
      resources :tags, except: %i(new edit)
      # resources :plans, only: %i(show index)
      resources :interactions, only: %i(index show create)
      resources :monthly_billings, only: %i(index)
    end
  end

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end unless Rails.env.development?
  mount Sidekiq::Web => '/sidekiq'

  get '/:page', controller: 'frontend', action: 'render_page'
  get '/', controller: 'frontend', action: 'index'

  match '*path', via: :all, to: 'application#render_404'
end
