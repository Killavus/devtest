class CreateTargetGroups < ActiveRecord::Migration
  def up 
    create_table :target_groups do |t|
      t.string :name, null: false
      t.uuid :external_id, null: false, default: 'gen_random_uuid()'
      t.references :parent, index: true
      t.string :secret_code, null: false
      t.references :panel_provider, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_foreign_key :target_groups, :target_groups, column: :parent_id, primary_key: :id
  end

  def down
    remove_foreign_key :target_groups, :target_groups, column: :parent_id, primary_key: :id
    drop_table :target_groups
  end
end
