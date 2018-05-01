require 'ostruct'
require 'byebug'
require 'Qoo10'
require 'carousell'
require 'lazada'

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
		else
			@query = Query.new
			@query.name = params[:name]
			@query.user_id = @current_user.id
			@query.save!

			qoo10 = Qoo10Scraper.new(@query.name)
			qoo10.search
			parsedQoo10 =JSON.parse(qoo10.results, object_class: OpenStruct)
			addToResults(parsedQoo10,"Qoo10")
			qoo10_average_price = qoo10.average_price(qoo10.results)
			qoo10_total_items = qoo10.total_results
			addToSellerDetails_Qoo10(qoo10_average_price, qoo10_total_items)

			lazada = LazadaScraper.new
			lazada.scrap(@query.name)
			parsedLazada = JSON.parse(lazada.cheapest_products, object_class: OpenStruct)
			addToResults(parsedLazada,"Lazada")
			lazada_average_price = lazada.average_price
      		lazada_total_items = lazada.total_results
			addToSellerDetails_Lazada(lazada_average_price, lazada_total_items)

			carousell = CarousellScraper.new(@query.name)
			carousell.scrap
			parsedCarousell =JSON.parse(carousell.results, object_class: OpenStruct)
			addToResults(parsedCarousell,"Carousell")
			carousell_average_price = carousell.average_price
			addToSellerDetails_Carousell(carousell_average_price)

      		# Save popular products for lazada platform if it has not been saved before
			if PopularProduct.where(platform: 'Lazada').length == 0
			lazada.scrap_popular_products
	      	popular_products = JSON.parse(lazada.popular_results, object_class: OpenStruct)
	      	popular_products.each do |popular_product|
	        		lazada_popular_result = PopularProduct.create(name: popular_product["name"], platform: popular_product["platform"])
	        		lazada_popular_result.save
	      		end
			end

			# Save popular products for Qoo10 platform if it has not been saved before
			if PopularProduct.where(platform: 'Qoo10').length == 0
				qoo10_bestSeller = JSON.parse(qoo10.bestSellers, object_class: OpenStruct)
				qoo10_bestSeller.each do |qoo10_product|
					qoo10_popular_result = PopularProduct.create(name: qoo10_product["name"], platform: "Qoo10")
					qoo10_popular_result.save
				end
			end

			# Save popular products for Carousell platform if it has not been saved before
			# if PopularProduct.where(platform: 'Carousell').length == 0
			# 	carousell_bestSeller = JSON.parse(carousell.bestSellers, object_class: OpenStruct)
			# 	carousell_bestSeller.each do |carousell_product|
			# 		carousell_popular_result = PopularProduct.create(name: carousell_product["name"], platform: "Carousell")
			# 		carousell_popular_result.save
			# 	end
			# end 

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
	
	def addToResults(hash,platform)
		hash.each do |item|
			result = Result.create(name: item["name"], img: item["img"], price: item["price"], url: item["url"], platform: platform, favourited: false, query_id: @query.id)
			result.save
		end
	end

	def addToSellerDetails_Lazada(avg_price, total_items)
		# puts "Lazada average price => #{avg_price}"
		# puts "Lazada total items found => #{total_items}"
		lazada_seller_detail_result = SellerDetail.create(platform: "Lazada", avg_price: avg_price, count: total_items, query_id: @query.id)
		lazada_seller_detail_result.save!
	end

	def addToSellerDetails_Qoo10(avg_price, total_items)
		# puts "Qoo10 average price => #{avg_price}"
		# puts "Qoo10 total items found => #{total_items}"
		qoo10_seller_detail_result = SellerDetail.create(platform: "Qoo10", avg_price: avg_price, count: total_items.to_i, query_id: @query.id)
		qoo10_seller_detail_result.save!
	end

	def addToSellerDetails_Carousell(avg_price)
		# puts "Carousell average price => #{avg_price}"
		carousell_seller_detail_result = SellerDetail.create(platform: "Carousell", avg_price: avg_price, count: 0, query_id: @query.id)
		carousell_seller_detail_result.save!
	end	
end
