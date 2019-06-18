class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[slack]

  has_many :surveys
  belongs_to :team

  def email_required?
    super && provider.blank?
  end

  def self.from_omniauth(auth)
    # TO DO: Connect team_id as foreign key to TEAM table
    where(provider: auth.provider, uid: auth.uid, tid: auth.info.team_id).first_or_create do |user|
      user.provider = auth.provider
      if auth.info[:name].nil?
        user.first_name = auth.info[:user]
        user.last_name = ""
      else
        user.first_name = auth.info[:name].split.first
        user.last_name = auth.info[:name].split.last
      end
      user.uid = auth.uid
      user.tid = auth.info.team_id
      # Makes Cameron's user on the Critiq workspace an admin
      if auth.info.team_id == "TK2V38Q07" && auth.info.user_id == "UK14YMUQY"
        user.admin = true
      end
      user.team = Team.where(team_id: auth.info.team_id).first
      user.nickname = auth.info.nickname unless auth.info.nickname.nil?
      user.password = Devise.friendly_token[0,20]
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.slack_data"] && session["devise.slack_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
end
