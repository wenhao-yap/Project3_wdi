Rails.application.routes.draw do
	root 'queries#index'
	get '/sign-up', to: 'users#new'
	get '/log-in', to: 'users#login'
	get '/user/profile', to: 'users#profile'
	get '/admin/profile', to: 'users#admin'
	get '/about', to: 'queries#about'

	# devise_for :users
 #  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
 #  resources :queries do
 #  	resources :favourites
 #  end

  resources :queries
end
