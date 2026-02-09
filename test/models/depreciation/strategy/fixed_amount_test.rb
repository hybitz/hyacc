require 'test_helper'

module Depreciation::Strategy
  class FixedAmountTest < ActiveSupport::TestCase

    def test_create_depreciations_5_years
      asset = Asset.find(1)
      asset.depreciation_method = DEPRECIATION_METHOD_FIXED_AMOUNT
      Depreciation::DepreciationUtil.create_depreciations(asset)
      assert_nothing_raised{ asset.save! }
      
      assert_equal 2009, asset.start_fiscal_year
      assert_equal 2013, asset.end_fiscal_year
      assert_equal 5, asset.depreciations.size
      assert_equal 100000, asset.depreciations[0].amount_at_start
      assert_equal 80000, asset.depreciations[0].amount_at_end
      assert_equal 80000, asset.depreciations[1].amount_at_start
      assert_equal 60000, asset.depreciations[1].amount_at_end
      assert_equal 60000, asset.depreciations[2].amount_at_start
      assert_equal 40000, asset.depreciations[2].amount_at_end
      assert_equal 40000, asset.depreciations[3].amount_at_start
      assert_equal 20000, asset.depreciations[3].amount_at_end
      assert_equal 20000, asset.depreciations[4].amount_at_start
      assert_equal 1, asset.depreciations[4].amount_at_end
    end

    def test_年度途中で取得した資産
      asset = Asset.find(1)
      asset.ym = 200906
      asset.depreciation_method = DEPRECIATION_METHOD_FIXED_AMOUNT
      Depreciation::DepreciationUtil.create_depreciations(asset)
      assert_nothing_raised{ asset.save! }
      
      assert_equal 2009, asset.start_fiscal_year
      assert_equal 2014, asset.end_fiscal_year
      assert_equal 6, asset.depreciations.size
      assert_equal 100000, asset.depreciations[0].amount_at_start
      assert_equal 90000, asset.depreciations[0].amount_at_end
      assert_equal 90000, asset.depreciations[1].amount_at_start
      assert_equal 70000, asset.depreciations[1].amount_at_end
      assert_equal 70000, asset.depreciations[2].amount_at_start
      assert_equal 50000, asset.depreciations[2].amount_at_end
      assert_equal 50000, asset.depreciations[3].amount_at_start
      assert_equal 30000, asset.depreciations[3].amount_at_end
      assert_equal 30000, asset.depreciations[4].amount_at_start
      assert_equal 10000, asset.depreciations[4].amount_at_end
      assert_equal 10000, asset.depreciations[5].amount_at_start
      assert_equal 1, asset.depreciations[5].amount_at_end
    end
    
  end
end
