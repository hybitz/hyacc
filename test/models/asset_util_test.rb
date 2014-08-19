require 'test_helper'

class AssetUtilTest < ActiveSupport::TestCase
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
