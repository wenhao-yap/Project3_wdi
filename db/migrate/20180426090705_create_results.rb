class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.string :name
      t.string :img
      t.string :price
      t.string :url
      t.text :platform
      t.references :query, foreign_key: true

      t.timestamps
    end
  end
end
