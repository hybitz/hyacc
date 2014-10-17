module CurrentCompany
  extend ActiveSupport::Concern

  included do
    helper_method :current_company
  end

  def current_company
    current_user.company if user_signed_in?
  end

end