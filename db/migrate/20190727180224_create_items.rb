class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.string :description
      t.decimal :price, precision: 10, scale: 2
      t.integer :stockQty

      t.timestamps
    end
  end
end
