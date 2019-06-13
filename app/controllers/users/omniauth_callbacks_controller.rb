class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def slack
    # You need to implement the method below in your model (e.g. app/models/user.rb)

    user_team = Team.where(team_id: request.env["omniauth.auth"]["info"]["team_id"])

    if user_team.exists? && user_team.first.active
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, kind: "Slack") if is_navigational_format?
      else
        session["devise.slack_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    else
      flash[:notice] = 'Your team has not installed Critiq: Do that before logging in.'
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path
  end
end
