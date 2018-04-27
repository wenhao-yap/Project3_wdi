class CreatePopularProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :popular_products do |t|
      t.string :name
      t.text :platform

      t.timestamps
    end
  end
end
