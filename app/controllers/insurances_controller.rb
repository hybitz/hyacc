class InsurancesController < Base::HyaccMasterController
  available_for :type => :company_type, :except => COMPANY_TYPE_PERSONAL
  view_attribute :title => '健康保険料'
  view_attribute :finder, :class => InsuranceFinder, :only => :index
  view_attribute :prefectures, :only => :index
end
