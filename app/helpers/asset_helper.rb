# coding: UTF-8
#
# $Id: asset_helper.rb 2914 2012-08-31 07:13:34Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module AssetHelper
  include HyaccViewHelper
  
  def colspan_of_asset_remarks
    return 3 if branch_mode
    2
  end
  
  def durable_years_editable?(depreciation_method)
    depreciation_method == DEPRECIATION_METHOD_LUMP
  end
  
  def render_ymd(asset)
    format_ymd(asset.ym, asset.day) 
  end
end
