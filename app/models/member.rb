class Member < ApplicationRecord
  # Model for all members of a given workspace
  validates :uid, :team, presence: true
  validates :uid, uniqueness: { scope: :team,
    message: "User ID's are unique within workspaces" }

  belongs_to :team
end
