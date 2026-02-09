module Bs::AssetsHelper
  include HyaccViewHelper
  
  def durable_years_editable?(depreciation_method)
    depreciation_method == DEPRECIATION_METHOD_LUMP
  end
  
end
