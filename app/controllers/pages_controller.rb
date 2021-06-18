class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [:home]
  # before_action :check_signed_in

  def home
  end
  # check if user is signed in. if is, get's redirected to the dashboard
  def check_signed_in
    redirect_to surveys_path if signed_in?
  end
end
