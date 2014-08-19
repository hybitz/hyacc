ActiveSupport.on_load :active_record do
  include Base::ActsAsCached
end
