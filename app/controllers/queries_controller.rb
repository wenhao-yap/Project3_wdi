require 'ostruct'
require 'byebug'
require 'Qoo10'
require 'carousell'
require 'lazada'

class QueriesController < ApplicationController
	before_action :authenticate_user!, :except => [ :index, :create ]
 
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
			parsedQoo10 = Result.where(platform: 'Qoo10', query_id: searched_query.id)
			parsedLazada = Result.where(platform: 'Lazada', query_id: searched_query.id)
			parsedCarousell = Result.where(platform: 'Carousell', query_id: searched_query.id)
			@parsedAll = [{platform:'Qoo10',results:parsedQoo10},{platform:'Lazada',results:parsedLazada},{platform:'Carousell',results:parsedCarousell}]
		# Query does not exist in the database
		else
			@query = Query.new(query_params)
			@query.user_id = current_user.id if current_user
			@query.save!
      
			qoo10 = Qoo10Scraper.new(@query.name)
			qoo10.search
			parsedQoo10 =JSON.parse(qoo10.results, object_class: OpenStruct)
			addToResults(parsedQoo10,"Qoo10")

			lazada = LazadaScraper.new(@query.name)
			lazada.scrap
			parsedLazada = JSON.parse(lazada.cheapest_products, object_class: OpenStruct)
			addToResults(parsedLazada,"Lazada")

			carousell = CarousellScraper.new(@query.name)
			carousell.scrap
			parsedCarousell =JSON.parse(carousell.results, object_class: OpenStruct)
			addToResults(parsedCarousell,"Carousell")

			@parsedAll = [{platform:'Qoo10',results:parsedQoo10},{platform:'Lazada',results:parsedLazada},{platform:'Carousell',results:parsedCarousell}]
      
      # Save the popular products into the database
      lazada.scrap_popular_products
      popular_products = JSON.parse(lazada.popular_results, object_class: OpenStruct)
      popular_products.each do |popular_product|
        lazada_popular_result = PopularProduct.create(name: popular_product["name"], platform: popular_product["platform"])
        lazada_popular_result.save
      end

      # Save the average_price and number of items found from the search query into the database
      average_price = lazada.average_price
      total_items = lazada.total_results
      seller_detail_result = SellerDetail.create(platform: "Lazada", avg_price: @average_price, count: @total_items, query_id: params[:id])
      seller_detail_result.save
		end
	end

	private
	def query_params
		current_user ? (params.permit(:name, current_user.id)) : (params.permit(:name))
	end

	def addToResults(hash,platform)
		hash.each do |item|
			result = Result.create(name: item["name"], img: item["img"], price: item["price"], url: item["url"], platform: platform, query_id: @query.id)
			result.save
		end		
	end
end
