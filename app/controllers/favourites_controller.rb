class FavouritesController < ApplicationController
  def index
  end

  def create
    user_id = current_user.id
    query_id = params[:id]

  end


  private
	def query_params
		params.permit(:name)
	end
end
