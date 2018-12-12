Rails.application.routes.draw do
  get 'custom_message/index'
  resource :user, only: [:show, :create]
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
  post   '/callback', to: 'callback#callback'
  post   '/callback/:hash', to: 'callback#callback'

  get '/google_auth/redirect/:bot_id', to: 'google_auth#redirect'
  get '/google_auth/callback/:hash', to: 'google_auth#callback'
  get '/google_auth/create_event'
  get '/google_auth/get_events'


  constraints(id: /[0-9]+/, bot_id: /[0-9]+/) do
    resources :bot, except: [:new, :index] do
      resources :response_data, only: [:index], shallow: true
      resources :forms, shallow: true do
        member do
          patch :switch_active
        end
        resources :quick_replies, only: [:create, :destroy], shallow: true do
          resources :quick_reply_items, only: [:create, :destroy], shallow: true
        end
      end
      resources :custom_message, only: [:index], shallow: true do
        collection do
          get :search
        end
      end
      resources :remind, except: [:new, :show, :index]#, shallow: true
      resources :lineusers, only: [:show, :index, :edit], shallow: true
      resources :chat, only: [:show, :index], param: :lineuser_id do#, shallow: true
        member do
          post :create
          patch :update_name
        end
      end
    end
  end
  root to: 'users#new'
  match "*path" => "application#render_404", via: :all
end