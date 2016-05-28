module FirstBoot
  extend ActiveSupport::Concern
  include HyaccConstants

  included do
    skip_before_action :authenticate_user!
    before_action :check_first_boot
  end

  private

  def check_first_boot
    if User.count > 0
      redirect_to root_path if controller_name != 'welcome'
    else
      redirect_to first_boot_index_path if controller_name != 'first_boot'
    end
  end

end