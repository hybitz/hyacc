# coding: UTF-8
#
# $Id: asset_util_test.rb 3154 2013-12-06 03:16:47Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class AssetUtilTest < ActiveRecord::TestCase
  include AssetUtil
  
  def test_資産コードを発番
    assert_equal '20090002', create_asset_code(2009)
  end

  def test_clear_asset_from_details
    jh = JournalHeader.find(6300)

    jh.journal_details.each do |jd|
      assert_not_nil(jd.asset) if jd.detail_no == 2
    end

    clear_asset_from_details(jh)
    
    jh.journal_details.each do |jd|
      assert_nil(jd.asset) if jd.detail_no == 2
    end
  end
end
