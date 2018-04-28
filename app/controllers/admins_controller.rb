class AdminsController < ApplicationController
	before_action :ensure_admin_user!

	def home
	end

	def ensure_admin_user!
		unless current_user and current_user.admin?
			flash[:alert] = "You don't have sufficient credentials to access this page."
			redirect_to root_path
		end
	end
end
