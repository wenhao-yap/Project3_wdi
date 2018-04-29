class Admin::DashboardsController < ApplicationController
  before_action :ensure_admin_user!

  # Gather data from database to be displayed on dashboard
  def index
    
  end

  	private
	def ensure_admin_user!
		unless current_user and current_user.admin?
			flash[:alert] = "You don't have sufficient credentials to access this page."
			redirect_to root_path
		end
	end
end
