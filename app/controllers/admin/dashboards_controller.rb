class Admin::DashboardsController < ApplicationController
  before_action :ensure_admin_user!

  # Gather data from database to be displayed on dashboard
  def index
    # Get the popular products for each platform
    @qoo10_popular_products = PopularProduct.where(platform: 'Qoo10')
    @lazada_popular_products = PopularProduct.where(platform: 'Lazada')
    @carousell_popular_products = PopularProduct.where(platform: 'Carousell')

    # Get the total number of items found for searched query for each platform
    # @qoo10_total_items_found =
    # @lazada_total_items_found =
    # @carousell_total_items_found =

    # Get the average price for the searched query for each platform
    # @qoo10_average_price =
    # @lazada_average_price =
    # @carousell_average_price =
  end

  	private
	def ensure_admin_user!
		unless current_user and current_user.admin?
			flash[:alert] = "You don't have sufficient credentials to access this page."
			redirect_to root_path
		end
	end

  def scrap_qoo10_popular_items_found(qoo10_popular_products)

  end

  def scrap_lazada_popular_items_found(lazada_popular_products)

  end
end
