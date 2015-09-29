require 'test_helper'

class JournalUtilTest < ActiveSupport::TestCase
  include JournalUtil
  
  def test_clear_detail_attributes
    jd = clear_detail_attributes(JournalDetail.find(3))
    assert_equal 3, jd.id
    assert_nil jd.journal_header_id
    assert_nil jd.detail_no
    assert_nil jd.dc_type
    assert_nil jd.account_id
    assert_nil jd.sub_account_id
    assert_nil jd.branch_id
    assert_nil jd.amount
    assert_nil jd.updated_on
    assert_nil jd.note
    assert_nil jd.social_expense_number_of_people
    assert_equal DETAIL_TYPE_NORMAL, jd.detail_type
    assert_equal TAX_TYPE_NONTAXABLE, jd.tax_type
    assert_nil jd.main_detail_id
  end

  def test_calc_amount
    assert_equal 100, calc_amount(TAX_TYPE_NONTAXABLE, 100, 5)
    assert_equal 96, calc_amount(TAX_TYPE_INCLUSIVE, 100, 4)
    assert_equal 100, calc_amount(TAX_TYPE_EXCLUSIVE, 100, 5)
  end
  
  def test_get_all_related_journals
    journal = JournalHeader.new
    journal.transfer_journals << JournalHeader.new
    journal.transfer_journals[0].transfer_journals << JournalHeader.new
    assert_equal(3, get_all_related_journals(journal).length)
    
    journal.transfer_journals << JournalHeader.new
    assert_equal(4, get_all_related_journals(journal).length)
  end

end
