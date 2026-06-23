class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers

  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  def authenticate_user!
    return if current_user
    save_passwordless_redirect_location!(User)
    redirect_to auth_sign_in_path, alert: "Sign in to continue."
  end
end
