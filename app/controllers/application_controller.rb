class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :check_first_boot
  before_action :authenticate_user!

  include CurrentCompany
  include Title
  
  rescue_from StrongActions::ForbiddenAction do
    if user_signed_in?
      render file: 'public/403.html', layout: false, status: :forbidden
    else
      redirect_to root_path
    end
  end

  private

  # インストールほやほやかどうかチェックする
  def check_first_boot
    if User.count == 0 and Company.count == 0
      redirect_to controller: 'first_boot' and return
    end
  end

end
