class InsurancesController < Base::HyaccMasterController
  view_attribute :title => '健康保険料'
  view_attribute :finder, :class => InsuranceFinder, :only => :index
  view_attribute :prefectures, :only => :index
end
