module Bs::AssetsHelper
  include HyaccViewHelper
  
  def durable_years_editable?(depreciation_method)
    depreciation_method == DEPRECIATION_METHOD_LUMP
  end
  
  def render_ymd(asset)
    format_ymd(asset.ym, asset.day) 
  end
end
