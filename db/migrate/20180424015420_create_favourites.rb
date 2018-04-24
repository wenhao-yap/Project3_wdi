class CreateFavourites < ActiveRecord::Migration[5.2]
  def change
    create_table :favourites do |t|
      t.text :name
      t.text :price
      t.text :img
      t.text :platform
      t.references :query, foreign_key: true

      t.timestamps
    end
  end
end
