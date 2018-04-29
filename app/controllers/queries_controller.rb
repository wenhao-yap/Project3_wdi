require 'Qoo10'
# require 'shopee'
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
			flash[:notice] = "You have not entered a search query"
			return redirect_to queries_path
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

	#Display search results
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

		# Get the cheapest products from the data scrapped
		lazada = LazadaScraper.new
		lazada.scrap(@query.name)
		@parsedLazada = JSON.parse(lazada.cheapest_products, object_class: OpenStruct)

		# Save the popular products into the database
		lazada.scrap_popular_products
		@popular_products = JSON.parse(lazada.popular_results, object_class: OpenStruct)
		@popular_products.each do |popular_product|
			@popular_result = PopularProduct.create(name: popular_product["name"], platform: popular_product["platform"])
			@popular_result.save
		end

		# Save the average_price and number of items found from the search query into the database
		@average_price = lazada.average_price
		@total_items = lazada.total_results
		@seller_detail_result = SellerDetail.create(platform: "Lazada", avg_price: @average_price, count: @total_items, query_id: params[:id])
		@seller_detail_result.save

		# Save the search results into the database
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
