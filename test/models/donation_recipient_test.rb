require 'test_helper'

class DonationRecipientTest < ActiveSupport::TestCase
  def test_has_deleted_column_and_deleted_predicate
    dr = donation_recipients(:one)
    assert_equal false, dr.deleted?
    dr.deleted = true
    assert dr.deleted?
  end

  def test_not_deleted_scope_excludes_logically_deleted
    assert_includes DonationRecipient.not_deleted, donation_recipients(:one)
    assert_not_includes DonationRecipient.not_deleted, donation_recipients(:deleted_one)
  end

  def test_destroy_logically_marks_deleted
    dr = donation_recipients(:for_deletion)
    dr.destroy_logically!
    assert dr.reload.deleted?
  end

  def test_company_donation_recipients_excludes_deleted
    company = Company.find(1)
    assert_not_includes company.donation_recipients, donation_recipients(:deleted_one)
  end

  def test_label_for_select_指定は公告番号または使途
    dr = donation_recipients(:one)
    assert_equal 'テスト寄付先（1-2345）', dr.label_for_select
  end

  def test_label_for_select_特定公益増進は使途又は名称
    dr = donation_recipients(:public_interest)
    assert_equal '特定公益増進テスト（使途名）', dr.label_for_select
  end

  def test_label_for_select_非認定信託は信託名
    dr = donation_recipients(:non_certified_trust)
    assert_equal '非認定信託テスト（信託名）', dr.label_for_select
  end

  def test_label_for_select_識別値がなければ名称のみ
    dr = donation_recipients(:one)
    dr.announcement_number = nil
    dr.purpose = nil
    assert_equal 'テスト寄付先', dr.label_for_select
  end

  def test_validates_name_presence
    dr = DonationRecipient.new(kind: SUB_ACCOUNT_CODE_DONATION_DESIGNATED, name: '', company_id: 1)
    assert_not dr.valid?
    assert dr.errors[:name].present?
  end

  def test_validates_kind_inclusion
    dr = DonationRecipient.new(kind: '999', name: 'テスト', company_id: 1)
    assert_not dr.valid?
    assert dr.errors[:kind].present?
  end
end
