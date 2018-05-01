class Admin::DashboardsController < ApplicationController
  	before_action :ensure_admin_user!
  	layout "admin"  

  	# Gather data from database to be displayed on dashboard
  	def index
  	end

  	def new
  		@query = Query.new
  	end

  	def create
  		params[:name].downcase!
  		if Query.find_by(name: params[:name])
			@query = Query.new
			@query.name = params[:name]
			searched_query = Query.find_by(name: params[:name])
			parsedQoo10 = Result.where(platform: 'Qoo10', query_id: searched_query.id)
			parsedLazada = Result.where(platform: 'Lazada', query_id: searched_query.id)
			parsedCarousell = Result.where(platform: 'Carousell', query_id: searched_query.id)
			@parsedAll = [{platform:'Qoo10',results:parsedQoo10},{platform:'Lazada',results:parsedLazada},{platform:'Carousell',results:parsedCarousell}]
		end
  	end

  	private
	def ensure_admin_user!
		unless current_user and current_user.admin?
			flash[:alert] = "You don't have sufficient credentials to access this page."
			redirect_to root_path
		end
	end
end
