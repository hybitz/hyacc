class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  include CurrentCompany
  include Title
  
  rescue_from StrongActions::ForbiddenAction do
    render :file => 'public/403.html', :layout => false, :status => :forbidden
  end

end
