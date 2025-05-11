class ApplicationController < ActionController::Base
  layout :layout_by_resource

  private

  def layout_by_resource
    if user_signed_in?
      "authenticated"
    else
      "application"
    end
  end
end
