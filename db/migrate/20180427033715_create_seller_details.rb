class CreateSellerDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :seller_details do |t|
      t.string :platform
      t.text :avg_price
      t.integer :count
      t.references :query, foreign_key: true

      t.timestamps
    end
  end
end
