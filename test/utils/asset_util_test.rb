require 'test_helper'

class AssetUtilTest < ActiveSupport::TestCase
  include HyaccConst
  
  def setup
    @old_journal = Asset.find_by(status: ASSET_STATUS_WAITING).journal_detail.journal
    @new_journal = Journal.find(@old_journal.id)
  end

  def test_no_update_should_skip_asset_validation
    assert_nothing_raised do
      AssetUtil.validate_assets(@new_journal, @old_journal)
    end
  end

  def test_receipt_only_update_should_skip_asset_validation
    @new_journal.build_receipt(file: 'new_receipt.pdf')

    assert_nothing_raised do
      AssetUtil.validate_assets(@new_journal, @old_journal)
    end
  end

  def test_journal_update_should_trigger_asset_validation
    @new_journal.remarks = '摘要の変更'
    assert_raises(HyaccException) do
      AssetUtil.validate_assets(@new_journal, @old_journal)
    end
  end

  def test_journal_detail_update_should_trigger_asset_validation
    @new_journal.journal_details.each {|jd| jd.amount += 100}

    assert_raises(HyaccException) do
      AssetUtil.validate_assets(@new_journal, @old_journal)
    end
  end
end