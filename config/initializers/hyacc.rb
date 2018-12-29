ActiveSupport.on_load :active_record do
  ActiveRecord::Base.logger = nil if Rails.env.development?
  include HyaccConstants
end

ActiveSupport.on_load :action_view do
  module ActionView::CompiledTemplates
    include HyaccConstants
  end
end
