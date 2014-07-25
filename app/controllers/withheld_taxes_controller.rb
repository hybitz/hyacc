class WithheldTaxesController < Base::BasicMasterController
  available_for :type => :company_type, :except => COMPANY_TYPE_PERSONAL
  view_attribute :title => '源泉徴収税'
end
