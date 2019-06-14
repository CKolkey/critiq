class AddEncryptionColumnsToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :encrypted_token, :binary
    add_column :teams, :encrypted_token_iv, :binary
    add_column :teams, :encrypted_bot_access_token, :binary
    add_column :teams, :encrypted_bot_access_token_iv, :binary
  end
end
