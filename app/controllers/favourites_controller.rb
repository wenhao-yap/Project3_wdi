class FavouritesController < ApplicationController
  layout "front"

  def index
    favourites = Favourite.where(user_id: current_user.id)

    @favourites = []
    keys = [:id, :result_id, :name, :price, :platform, :img, :url]

    favourites.each do |favourite|
      result = Result.find(favourite.result_id)
      result_id = favourite.result_id
      next if result.url == nil
      fav = Hash[keys.map {|x| [x,1]}]
      fav[:id] = result.id
      fav[:result_id] = result_id
      fav[:name] = result.name
      fav[:price] = result.price
      fav[:platform] = result.platform
      fav[:img] = result.img
      fav[:url] = result.url
      @favourites << fav
    end

    JSON.pretty_generate(@favourites)
  end

  def create
    if current_user
      item = Result.find_by(name: params[:result_id])

      # Update favourited attribute boolean value to be true when a search result is added to favourites
      item.update(favourited: true)

      favourite = Favourite.create(user_id: current_user.id, result_id: item.id)
      favourite.save
    else
      redirect_to user_session_path
    end
  end

  def destroy
    favourite_id = Favourite.find_by(result_id: params[:result_id]).id
    puts "Id to be deleted => #{favourite_id}"

    item = Result.find(params[:result_id])
    item.update(favourited: false)

    Favourite.destroy(favourite_id)
    redirect_to result_favourites_path
  end

  private
	def query_params
		params.permit(:name)
	end
end
