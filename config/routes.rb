Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }
  devise_scope :user do
    authenticated :user do
      root 'posts#home', as: :authenticated_root
    end

    unauthenticated :user do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
  root 'devise/sessions#new'
  resources :posts do
    member do
      post "like", to: "posts#like"
      delete "unlike", to: "posts#unlike"
    end
  end
  resources :comments do
    member do
      post "like", to: "comments#like"
      delete "unlike", to: "comments#unlike"
    end
  end
  resources :users, only: [:show, :destroy, :update] do
    resources :friendships, only: [:index, :create] do
      collection do
        get :mutual_friends
      end
    end
  end
  resources :friendships, only: [:destroy]
  resources :notifications, only: [:index]
  get 'details', to: 'users#edit', as: 'details'
  get 'search', to: 'users#search'
end
