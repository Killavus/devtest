class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :country_code, null: false
      t.references :panel_provider, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
