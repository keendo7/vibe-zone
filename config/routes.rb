Rails.application.routes.draw do
  devise_for :users
  root "posts#home"
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
  resources :users, only: [:show, :destroy] do
    resources :friendships, only: [:index, :create]
  end
  resources :friendships, only: [:destroy]
  get 'notifications', to: 'friendships#notifications', as: 'notifications'
end
