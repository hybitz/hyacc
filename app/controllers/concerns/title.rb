module Title
  extend ActiveSupport::Concern

  included do
    helper_method :title
  end

  private

  def title
    @title ||= I18n.t("title.#{controller_name}")
  end

end