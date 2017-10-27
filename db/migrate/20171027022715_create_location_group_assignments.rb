class CreateLocationGroupAssignments < ActiveRecord::Migration
  def change
    create_table :location_group_assignments do |t|
      t.references :location_group, index: true, foreign_key: true
      t.references :location, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
