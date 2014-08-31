class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CurrentCompany

  rescue_from StrongActions::ForbiddenAction, :with => :render_403

  protected

  def render_403
    render :file => 'public/403.html', :layout => false, :status => :forbidden
  end

end
