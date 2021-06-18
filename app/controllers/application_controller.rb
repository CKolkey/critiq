class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # before_action :authenticate_user!

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  def current_user
    User.first_or_create!(first_name: "David", last_name: "Friedl", email: "david@liiiiiiist.me", password: "12345678", team: Team.create!(name: "Critiq Staff") )
  end

  protected
  # redirecting after log in enabled
  def after_sign_in_path_for(resource)
    surveys_path
  end

end
