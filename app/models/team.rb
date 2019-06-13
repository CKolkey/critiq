class Team < ApplicationRecord
  validates :team_id, uniqueness: true
  validates :team_id, :token, :bot_user_id, :bot_access_token, :name, presence: true

  has_many :users
end
