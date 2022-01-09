ActiveSupport.on_load :action_view do
  module ActionView::CompiledTemplates
    include HyaccConst
  end
end
