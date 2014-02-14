# -*- encoding : utf-8 -*-
#
# $Id: lump_test.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

module Depreciation::Strategy
  class LumpTest < ActiveRecord::TestCase
    include Depreciation::DepreciationUtil
    
    def test_create_depreciations
      asset = Asset.find(1)
      asset.depreciation_method = DEPRECIATION_METHOD_LUMP
      asset.depreciation_limit = 0
      asset.depreciations = create_depreciations(asset)
      assert_nothing_raised{ asset.save! }
      
      assert_equal 2009, asset.start_fiscal_year
      assert_equal 2009, asset.end_fiscal_year
      assert_equal 1, asset.depreciations.size
      assert_equal 100000, asset.depreciations[0].amount_at_start
      assert_equal 0, asset.depreciations[0].amount_at_end
      
      # 年度途中で取得した資産の場合
      asset.ym = 200906
      asset.depreciations = create_depreciations(asset)
      assert_nothing_raised{ asset.save! }
      
      assert_equal 2009, asset.start_fiscal_year
      assert_equal 2009, asset.end_fiscal_year
      assert_equal 1, asset.depreciations.size
      assert_equal 100000, asset.depreciations[0].amount_at_start
      assert_equal 0, asset.depreciations[0].amount_at_end
    end
    
  end
end
