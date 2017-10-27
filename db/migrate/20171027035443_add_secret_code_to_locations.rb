class AddSecretCodeToLocations < ActiveRecord::Migration
  def change
    change_table :locations do |t|
      t.string :secret_code
    end

    Location.find_each do |loc|
      loc.secret_code = SecureRandom.hex
      loc.save!
    end

    change_column :locations, :secret_code, :string, null: false
  end
end
