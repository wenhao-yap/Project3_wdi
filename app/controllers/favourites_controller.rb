class FavouritesController < ApplicationController
  def index
    favourites = Favourite.where(user_id: current_user.id)

    @favourites = []
    keys = [:id, :result_id, :name, :price, :img, :url]

    favourites.each do |favourite|
      result = Result.find(favourite.result_id)
      result_id = favourite.result_id
      fav = Hash[keys.map {|x| [x,1]}]
      fav[:id] = result.id
      fav[:result_id] = result_id
      fav[:name] = result.name
      fav[:price] = result.price
      fav[:img] = result.img
      fav[:url] = result.url
      @favourites << fav
    end

    JSON.pretty_generate(@favourites)
  end

  def create
    if current_user
      favourite = Favourite.create(user_id: current_user.id, result_id: params[:result_id])
      favourite.save
    else
      redirect_to user_session_path
    end
  end

  def destroy

  end

  private
	def query_params
		params.permit(:name)
	end
end
