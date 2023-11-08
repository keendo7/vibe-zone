Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "posts#home"
  resources :posts do
    member do
      post "like", to: "posts#like"
      delete "unlike", to: "posts#unlike"
    end
  end
  
  resources :comments
end
