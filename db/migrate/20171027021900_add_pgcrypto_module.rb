class AddPgcryptoModule < ActiveRecord::Migration
  def change
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"
  end
end
