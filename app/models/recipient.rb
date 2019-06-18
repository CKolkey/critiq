class Recipient < ApplicationRecord
  # Model for which MEMBERS have recieved a given survey
  belongs_to :survey
end
