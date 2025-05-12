class ApplicationController < ActionController::Base
  layout :layout_by_resource
  before_action :ensure_starter_chosen

  private

  def layout_by_resource
    if user_signed_in?
      "authenticated"
    else
      "application"
    end
  end

  def ensure_starter_chosen
    return unless user_signed_in?
    return if current_user.starter_chosen?
    return if devise_controller?
    return if request.path.start_with?('/starter') # evita loop
    return if request.path.start_with?('/users/sign_out') # permite logout

    redirect_to starter_selection_path
  end

end
