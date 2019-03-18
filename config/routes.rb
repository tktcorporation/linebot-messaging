Rails.application.routes.draw do
  get 'custom_message/index'
  resource :user, only: [:show, :create]
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
  post   '/callback', to: 'callback#callback'
  post   '/callback/:hash', to: 'callback#callback'

  get '/google_auth/test_create/:bot_id', to: 'google_auth#test_create'


  resources :google_auth, only: [] do
    collection do
      get :callback
      get :redirect
      post :set_token
    end
  end

  namespace :api, format: 'json' do
    resources :bot, except: [:new, :index] do
      resources :messages, only: [:show, :index], param: :lineuser_id do#, shallow: true
        member do
          post :create
          patch :update_name
        end
      end
    end
  end

  constraints(id: /[0-9]+/, bot_id: /[0-9]+/, lineuser_id: /[0-9]+/) do
    resources :bot, except: [:new, :index] do
      member do
        patch :set_images
      end
      scope module: 'bot' do
        resources :ab_tests do
          member do
            patch :switch_active
          end
        end
        resources :response_data, only: [:index], shallow: true
        resources :reply_actions
        resources :images, only: [:show], shallow: true
        resources :statuses, only: [:create, :destroy, :index], shallow: true
        resources :forms do
          member do
            patch :switch_active
            get :edit_flow
          end
          scope module: 'forms' do
            resources :check_notifications, only: [:create, :destroy, :index]
          end
          resources :quick_replies, only: [:create, :destroy, :update], shallow: true do
            member do
              patch :text_update
            end
            resources :quick_reply_items, only: [:create, :destroy], shallow: true
          end
        end
        resources :custom_message, only: [:index], shallow: true do
          collection do
            get :search
          end
        end
        resources :remind, except: [:new, :show, :index]#, shallow: true
        resources :lineusers, only: [:show, :index, :edit], shallow: true do
          resources :lineuser_statuses, only: [] do
            collection do
              post :create
              patch :update
              delete :destroy
            end
          end
        end
        resources :chat, only: [:show, :index], param: :lineuser_id do#, shallow: true
          member do
            post :push_flex
            post :create
            post :redirect
            patch :update_name
            post :push_image
          end
        end
      end
    end
  end
  root to: 'users#new'
  # match "*path" => "application#render_404", via: :all
end