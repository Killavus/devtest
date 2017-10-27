class CreateCountryTargetGroupAssignments < ActiveRecord::Migration
  def change
    create_table :country_target_group_assignments do |t|
      t.references :country, index: true, foreign_key: true
      t.references :target_group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
