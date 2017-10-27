class CreateLocationGroups < ActiveRecord::Migration
  def change
    create_table :location_groups do |t|
      t.string :name, null: false
      t.references :country, index: true, foreign_key: true
      t.references :panel_provider, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
