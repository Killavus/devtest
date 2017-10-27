class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.uuid :external_id, null: false, default: 'gen_random_uuid()'
      t.references :panel_provider, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
