class PensionsController < Base::HyaccMasterController
  view_attribute :title => '厚生年金保険料'
  view_attribute :finder, :class => PensionFinder, :only => :index
end
