require 'Qoo10'
require 'ostruct'

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
		qoo10 = Qoo10Scraper.new(@query.name)
		qoo10.search
		@parsedResults =JSON.parse(qoo10.results, object_class: OpenStruct)

		# @totalSellers = qoo10.totalSellers
	end

	private
	def query_params
		params.permit(:name)
	end
end
