Rails.application.routes.draw do
  devise_for :users
  root to: "application#index"

  namespace :api, defaults: {format: :json} do
    resources :text_messages, only: [:index, :create], path: 'text-messages'
    resources :contacts, only: [:index, :create, :update] do
      resources :text_messages, path: 'text-messages'
      resources :groups, only: [:create, :destroy]
      get '/suggest-groups', to: 'groups#suggest'
    end

    resources :groups, only: [:show] do
      post '/text-messages', to: 'group_text_messages#create'
      get '/text-messages', to: 'group_text_messages#index'
      get '/suggest-contacts', to: 'groups#suggest_contacts'
      get '/contacts', to: 'groups#contacts'
    end

    resources :phone_numbers, path: 'phone-numbers', only: [] do
      get '/search'
    end

    post '/receive-sms', to: 'text_messages#receive'
  end

end
