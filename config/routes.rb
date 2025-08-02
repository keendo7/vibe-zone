Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }
  devise_scope :user do
    unauthenticated do
      root 'devise/sessions#new'
    end
    authenticated :user do
      root 'posts#home', as: :authenticated_root
    end
  end
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

    post :replies, on: :member
  end
  resources :friendships, only: [:create, :destroy] do
    member do
      delete :decline
    end
  end
  resources :users, only: [:show, :destroy, :update] do
    get :mutual_friends, to: 'user_friendships#mutual_friends'
    resources :friendships, controller: 'user_friendships', only: [:index]
  end
  resources :notifications, only: [:index]
  get 'details', to: 'users#edit', as: 'details'
  get 'search', to: 'users#search'
  get 'home', to: 'posts#home'
  delete 'remove_banner', to: 'users#remove_banner'
  patch 'update_avatar', to: 'users#update_avatar'
  delete 'remove_avatar', to: 'users#remove_avatar'
  patch 'update_banner', to: 'users#update_banner'
end
