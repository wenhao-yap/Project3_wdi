require 'Qoo10'
require 'shopee'
require 'ostruct'
require 'lazada'
require 'byebug'

class QueriesController < ApplicationController

	before_action :authenticate_user!, :except => [ :show, :index, :create ]
  
	#search page
	def index
	end

	def new
		@query = Query.new
	end

	def create
		if params[:name] == ""
			@showError = "You have not entered a search query"
			return render 'index'
		end
		params[:name].downcase!
		# Query exists in the database
		if Query.find_by(name: params[:name])
			@query = Query.new
			@query.name = params[:name]
			searched_query = Query.find_by(name: params[:name])
			@parsedQoo10 = Result.where(platform: 'Qoo10', query_id: searched_query.id)
			# @parsedShopee = Result.where(platform: 'Shopee', , query_id: searched_query.id)
			@parsedLazada = Result.where(platform: 'Lazada', query_id: searched_query.id)
			puts "Before rendering show and after acquiring all the data from the database"
			render 'show'
		# Query does not exist in the database
		else
			@query = Query.new(query_params)
			@query.user_id = current_user.id if current_user
			@query.save!
			redirect_to @query
		end
	end

	#display search results
	def show
		@query = Query.find(params[:id])

		qoo10 = Qoo10Scraper.new(@query.name)
		qoo10.search
		@parsedQoo10 =JSON.parse(qoo10.results, object_class: OpenStruct)

		@parsedQoo10.each do |qoo10_item|
			@result = Result.create(name: qoo10_item["name"], img: qoo10_item["img"], price: qoo10_item["price"], url: qoo10_item["url"], platform: "Qoo10", query_id: params[:id])
			@result.save
		end

		# shopee = ShopeeScraper.new(@query.name)
		# @parsedShopee =JSON.parse(shopee.results, object_class: OpenStruct)
		# @parsedShopee.each do |shopee_item|
		# 	@result = Result.create(name: qoo10_item.name, img: qoo10_item.imageLink, price: qoo10_item.currPrice, url: qoo10_item.link, platform: "Shopee", query_id: params[:id])
		# 	@result.save
		# end

		lazada = LazadaScraper.new(@query.name)
		lazada.scrap
		@parsedLazada = JSON.parse(lazada.cheapest_products, object_class: OpenStruct)

		@parsedLazada.each do |lazada_item|
			@result = Result.create(name: lazada_item["name"], img: lazada_item["img"], price: lazada_item["price"], url: lazada_item["url"], platform: "Lazada", query_id: params[:id])
			@result.save
		end
	end

	private
	def query_params
		current_user ? (params.permit(:name, current_user.id)) : (params.permit(:name))
	end
end
