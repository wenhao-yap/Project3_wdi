class Admin::UsersController < ApplicationController
	def index
		@users = User.all	
	end

	def show
		@user = User.find(params[:id])
	end

	def edit
		@user = User.find(params[:id])
	end

	def new
		@user = User.new
	end

	def create
		@users = User.all
		@user = User.create(user_params)
	end	

	def update
		@users = User.all
		@user = User.find(params[:id])
		if params[:user][:password].blank?
		  params[:user].delete(:password)
		  params[:user].delete(:password_confirmation)
		end

		@user.update_attributes(user_params)
	end

  	def delete
   		@user = User.find(params[:user_id])
  	end

  	def destroy
  		@users = User.all
    	@user = User.find(params[:id])
    	@user.destroy
  	end

	private
  	def user_params
    	params.require(:user).permit(:name, :email, :admin, :password, :password_confirmation)
  	end
end
