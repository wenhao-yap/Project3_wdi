Rails.application.routes.draw do

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  	devise_scope :user do
    	get 'users/sign_out' => "devise/sessions#destroy"
	end

	resources :queries do
		resources :results
	end
  resources :queries

  resources :results do
    resources :favourites
  end
  resources :favourites

  namespace :admin do
    resources :users do
      #view for confirmation before deletion
      get "delete"
    end
    resources :dashboards, only: [:index]
    root 'dashboards#index'
  end

	root 'queries#index'

   #404 page. comment this to see the routing errors
   # get "*any", via: :all, to: "errors#not_found"
end
