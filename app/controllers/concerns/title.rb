module Title
  extend ActiveSupport::Concern

  included do
    helper_method :title
  end

  private

  def title
    @title
  end

end