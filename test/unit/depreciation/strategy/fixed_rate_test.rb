# -*- encoding : utf-8 -*-
#
# $Id: fixed_rate_test.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

module Depreciation::Strategy
  class FixedRateTest < ActiveRecord::TestCase
    include Depreciation::DepreciationUtil
    
    def test_create_depreciations_5_years
      asset = Asset.find(1)
      asset.depreciations = create_depreciations(asset)
      assert_nothing_raised{ asset.save! }
      
      assert_equal 2009, asset.start_fiscal_year
      assert_equal 2013, asset.end_fiscal_year
      assert_equal 5, asset.depreciations.size
      assert_equal 100000, asset.depreciations[0].amount_at_start
      assert_equal 50000, asset.depreciations[0].amount_at_end
      assert_equal 50000, asset.depreciations[1].amount_at_start
      assert_equal 25000, asset.depreciations[1].amount_at_end
      assert_equal 25000, asset.depreciations[2].amount_at_start
      assert_equal 12500, asset.depreciations[2].amount_at_end
      assert_equal 12500, asset.depreciations[3].amount_at_start
      assert_equal 6250, asset.depreciations[3].amount_at_end
      assert_equal 6250, asset.depreciations[4].amount_at_start
      assert_equal 1, asset.depreciations[4].amount_at_end
      
      # 年度途中で取得した資産の場合
      asset.ym = 200906
      asset.depreciations = create_depreciations(asset)
      assert_nothing_raised{ asset.save! }
      
      assert_equal 2009, asset.start_fiscal_year
      assert_equal 2013, asset.end_fiscal_year
      assert_equal 5, asset.depreciations.size
      assert_equal 100000, asset.depreciations[0].amount_at_start
      assert_equal 75000, asset.depreciations[0].amount_at_end
      assert_equal 75000, asset.depreciations[1].amount_at_start
      assert_equal 37500, asset.depreciations[1].amount_at_end
      assert_equal 37500, asset.depreciations[2].amount_at_start
      assert_equal 18750, asset.depreciations[2].amount_at_end
      assert_equal 18750, asset.depreciations[3].amount_at_start
      assert_equal 9375, asset.depreciations[3].amount_at_end
      assert_equal 9375, asset.depreciations[4].amount_at_start
      assert_equal 1, asset.depreciations[4].amount_at_end
    end
    
    def test_create_depreciations_10_years
      asset = Asset.find(1)
      asset.durable_years = 10
      asset.amount = 1000000
      asset.depreciations = create_depreciations(asset)
      assert_nothing_raised{ asset.save! }
      
      assert_equal 2009, asset.start_fiscal_year
      assert_equal 2018, asset.end_fiscal_year
      assert_equal 10, asset.depreciations.size
      assert_equal 1000000, asset.depreciations[0].amount_at_start
      assert_equal 750000, asset.depreciations[0].amount_at_end
      assert_equal 750000, asset.depreciations[1].amount_at_start
      assert_equal 562500, asset.depreciations[1].amount_at_end
      assert_equal 562500, asset.depreciations[2].amount_at_start
      assert_equal 421875, asset.depreciations[2].amount_at_end
      assert_equal 421875, asset.depreciations[3].amount_at_start
      assert_equal 316407, asset.depreciations[3].amount_at_end
      assert_equal 316407, asset.depreciations[4].amount_at_start
      assert_equal 237306, asset.depreciations[4].amount_at_end
      assert_equal 237306, asset.depreciations[5].amount_at_start
      assert_equal 177980, asset.depreciations[5].amount_at_end
      assert_equal 177980, asset.depreciations[6].amount_at_start
      assert_equal 133485, asset.depreciations[6].amount_at_end
      assert_equal 133485, asset.depreciations[7].amount_at_start
      assert_equal 88902, asset.depreciations[7].amount_at_end
      assert_equal 88902, asset.depreciations[8].amount_at_start
      assert_equal 44319, asset.depreciations[8].amount_at_end
      assert_equal 44319, asset.depreciations[9].amount_at_start
      assert_equal 1, asset.depreciations[9].amount_at_end
      
      # 年度途中で取得した資産の場合
      asset.ym = 200906
      asset.depreciations = create_depreciations(asset)
      assert_nothing_raised{ asset.save! }
      
      assert_equal 2009, asset.start_fiscal_year
      assert_equal 2018, asset.end_fiscal_year
      assert_equal 10, asset.depreciations.size
      assert_equal 1000000, asset.depreciations[0].amount_at_start
      assert_equal 875000, asset.depreciations[0].amount_at_end
      assert_equal 875000, asset.depreciations[1].amount_at_start
      assert_equal 656250, asset.depreciations[1].amount_at_end
      assert_equal 656250, asset.depreciations[2].amount_at_start
      assert_equal 492188, asset.depreciations[2].amount_at_end
      assert_equal 492188, asset.depreciations[3].amount_at_start
      assert_equal 369141, asset.depreciations[3].amount_at_end
      assert_equal 369141, asset.depreciations[4].amount_at_start
      assert_equal 276856, asset.depreciations[4].amount_at_end
      assert_equal 276856, asset.depreciations[5].amount_at_start
      assert_equal 207642, asset.depreciations[5].amount_at_end
      assert_equal 207642, asset.depreciations[6].amount_at_start
      assert_equal 155732, asset.depreciations[6].amount_at_end
      assert_equal 155732, asset.depreciations[7].amount_at_start
      assert_equal 103718, asset.depreciations[7].amount_at_end
      assert_equal 103718, asset.depreciations[8].amount_at_start
      assert_equal 51704, asset.depreciations[8].amount_at_end
      assert_equal 51704, asset.depreciations[9].amount_at_start
      assert_equal 1, asset.depreciations[9].amount_at_end
    end
  end
end
