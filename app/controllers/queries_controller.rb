require 'Qoo10'
require 'shopee'
require 'ostruct'
require 'lazada'

class QueriesController < ApplicationController

	#search page
	def index
	end

	def new
		@query = Query.new
	end

	def create
		params[:name].downcase!
		@query = Query.find_or_create_by(query_params)
		redirect_to @query
	end

	#display search results
	def show
		@query = Query.find(params[:id])
		qoo10 = Qoo10Scraper.new(@query.name)
		qoo10.search
		@parsedQoo10 =JSON.parse(qoo10.results, object_class: OpenStruct)

		shopee = ShopeeScraper.new(@query.name)
		@parsedShopee =JSON.parse(shopee.results, object_class: OpenStruct)

		lazada = LazadaScraper.new(@query.name)
		lazada.scrap
		@parsedLazada = JSON.parse(lazada.cheapest_products, object_class: OpenStruct)
	end

	private
	def query_params
		params.permit(:name)
	end
end
