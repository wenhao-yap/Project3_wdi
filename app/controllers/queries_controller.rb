class QueriesController < ApplicationController
	#search page
	def index
	end

	def new
		@query = Query.new
	end

	def create
		@query = Query.new(query_params)
		@query.save
		redirect_to @query
	end

	#display search results
	def show
		@query = Query.find(params[:id])
	end

	private
	def query_params
		params.permit(:name)
	end

end
