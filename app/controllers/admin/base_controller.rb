class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_app_admin!

  private

  def require_app_admin!
    redirect_to root_path, alert: "Not authorised." unless current_user.app_admin?
  end
end
