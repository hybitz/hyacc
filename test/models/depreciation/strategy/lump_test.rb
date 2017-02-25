require 'test_helper'

class Depreciation::Strategy::LumpTest < ActiveSupport::TestCase

  def test_create_depreciations
    asset.depreciation_method = DEPRECIATION_METHOD_LUMP
    asset.depreciation_limit = 0

    Depreciation::DepreciationUtil.create_depreciations(asset)
    assert asset.save
    
    assert_equal 2009, asset.start_fiscal_year
    assert_equal 2009, asset.end_fiscal_year
    assert_equal 1, asset.depreciations.size
    assert_equal 100_000, asset.depreciations[0].amount_at_start
    assert_equal 0, asset.depreciations[0].amount_at_end
  end

  def test_年度途中で取得した資産
    asset.depreciation_method = DEPRECIATION_METHOD_LUMP
    asset.depreciation_limit = 0
    asset.ym = 200906
    

    Depreciation::DepreciationUtil.create_depreciations(asset)
    assert asset.save
    
    assert_equal 2009, asset.start_fiscal_year
    assert_equal 2009, asset.end_fiscal_year
    assert_equal 1, asset.depreciations.size
    assert_equal 100_000, asset.depreciations[0].amount_at_start
    assert_equal 0, asset.depreciations[0].amount_at_end
  end
    
end
