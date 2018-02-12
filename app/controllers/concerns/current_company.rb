module CurrentCompany
  extend ActiveSupport::Concern

  included do
    helper_method :current_company
  end

  private

  def current_company
    return false unless user_signed_in?
    current_user.employee && current_user.employee.company
  end

end