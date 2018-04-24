class CreateQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :queries do |t|
      t.text :name

      t.timestamps
    end
  end
end
