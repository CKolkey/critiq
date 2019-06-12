class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[slack]

  has_many :surveys

  def email_required?
    super && provider.blank?
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid, team_id: auth.info.team_id).first_or_create do |user|
      user.provider = auth.provider
      user.first_name = auth.info[:name].split.first
      user.last_name = auth.info[:name].split.last
      user.uid = auth.uid
      user.team_id = auth.info.team_id
      user.nickname = auth.info.nickname
      user.password = Devise.friendly_token[0,20]
    end
  end
end
