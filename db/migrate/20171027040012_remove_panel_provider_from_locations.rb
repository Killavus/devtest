class RemovePanelProviderFromLocations < ActiveRecord::Migration
  def change
    remove_column :locations, :panel_provider_id
  end
end
