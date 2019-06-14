class Team < ApplicationRecord
  validates :team_id, uniqueness: true
  validates :team_id, :encrypted_token, :bot_user_id, :encrypted_bot_access_token, :name, presence: true
  attr_encrypted :token, key: ENV['DB_ENCRYPTION_KEY']
  attr_encrypted :bot_access_token, key: ENV['DB_ENCRYPTION_KEY']

  has_many :users
end
