Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  	resources :queries do
  		resources :favourites
	end

	resources :queries

	root 'queries#index'
end
