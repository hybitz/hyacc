require 'test_helper'

class JournalDetailTest < ActiveSupport::TestCase

  def test_account_id_required

    # テスト前は正常に保存できることを前提とする
    @jd = JournalDetail.find(11573)
    assert_nothing_raised{ @jd.save! }

    # 未設定は認めない
    @jd.account_id = nil
    assert @jd.invalid?
  end

  def test_branch_id_required
    # テスト前は正常に保存できることを前提とする
    @jd = JournalDetail.find(11573)
    assert_nothing_raised{ @jd.save! }

    # 未設定は認めない
    @jd.branch_id = nil
    assert_raise( ActiveRecord::RecordInvalid ){ @jd.save! }
  end

  def test_補助科目の必須な勘定科目
    @jd = JournalDetail.find(11573)
    assert @jd.valid?

    @jd.account_id = Account.not_deleted.find {|a| a.has_sub_accounts? }.id

    @jd.sub_account_id = nil
    assert @jd.invalid?
    assert @jd.errors[:sub_account].any?

    @jd.sub_account_id = @jd.account.sub_accounts.first.id
    assert @jd.valid?
    assert @jd.errors[:sub_account].empty?
  end

  def test_amount_required
    # テスト前は正常に保存できることを前提とする
    @jd = JournalDetail.find(11573)
    assert_nothing_raised{ @jd.save! }

    # 未設定は認めない
    @jd.amount = nil
    assert_raise( ActiveRecord::RecordInvalid ){ @jd.save! }
  end

  def test_消費税率の必須チェック
    @jd = JournalDetail.new
    @jd.tax_rate = ''

    @jd.tax_type = TAX_TYPE_NONTAXABLE
    assert @jd.tax_rate.blank?
    assert @jd.invalid?
    assert @jd.errors[:tax_rate].empty?

    @jd.tax_type = TAX_TYPE_INCLUSIVE
    assert @jd.tax_rate.blank?
    assert @jd.invalid?
    assert @jd.errors[:tax_rate].present?

    @jd.tax_type = TAX_TYPE_EXCLUSIVE
    assert @jd.tax_rate.blank?
    assert @jd.invalid?
    assert @jd.errors[:tax_rate].present?
  end

  def test_勘定科目変更で無効な補助科目と寄付先は自動クリアされる
    jd = JournalDetail.find(49649)
    assert_equal ACCOUNT_CODE_DONATION, jd.account.code
    assert jd.sub_account_id.present?
    assert jd.donation_recipient_id.present?

    other_account = Account.find_by_code(ACCOUNT_CODE_PAID_FEE)
    jd.account_id = other_account.id

    jd.save!
    jd.reload
    assert_equal other_account.id, jd.account_id
    assert_nil jd.sub_account_id
    assert_nil jd.donation_recipient_id
  end

  def test_寄付金の補助科目をその他へ変更すると寄付先は自動クリアされる
    jd = JournalDetail.find(49649)
    assert_equal ACCOUNT_CODE_DONATION, jd.account.code
    assert jd.donation_recipient_id.present?

    others = SubAccount.find_by(code: SUB_ACCOUNT_CODE_DONATION_OTHERS, account_id: jd.account_id)
    previous_sub_account_id = jd.sub_account_id
    assert_not_equal others.id, previous_sub_account_id

    jd.sub_account_id = others.id

    jd.save!
    jd.reload
    assert_equal others.id, jd.sub_account_id
    assert_nil jd.donation_recipient_id
  end

  def test_寄付金の補助科目がその他で種別未設定寄付先なら保持される
    jd = JournalDetail.find(49649)
    assert_equal ACCOUNT_CODE_DONATION, jd.account.code

    others = SubAccount.find_by(code: SUB_ACCOUNT_CODE_DONATION_OTHERS, account_id: jd.account_id)
    kind_nil = donation_recipients(:kind_nil)
    assert_nil kind_nil.kind

    jd.sub_account_id = others.id
    jd.donation_recipient_id = kind_nil.id

    jd.save!
    jd.reload
    assert_equal others.id, jd.sub_account_id
    assert_equal kind_nil.id, jd.donation_recipient_id
  end

  def test_勘定科目と補助科目に変更がない更新でも不正な寄付先は自動クリアされる
    jd = JournalDetail.find(49649)
    assert_not jd.new_record?
    non_existing_recipient_id = DonationRecipient.maximum(:id).to_i + 1
    assert_nil DonationRecipient.find_by(id: non_existing_recipient_id)
    jd.donation_recipient_id = non_existing_recipient_id
    jd.save!
    jd.reload
    assert_nil jd.donation_recipient_id
  end

  def test_new_recordでも不正な寄付先は自動クリアされる
    source = JournalDetail.find(49649)
    jd = source.dup
    jd.detail_no = JournalDetail.where(journal_id: jd.journal_id).maximum(:detail_no).to_i + 1
    assert jd.new_record?
    non_existing_recipient_id = DonationRecipient.maximum(:id).to_i + 1
    assert_nil DonationRecipient.find_by(id: non_existing_recipient_id)
    jd.donation_recipient_id = non_existing_recipient_id
    jd.save!
    jd.reload
    assert_nil jd.donation_recipient_id
  end

  def test_new_recordで論理削除済みの寄付先は自動クリアされる
    source = JournalDetail.find(49649)
    jd = source.dup
    jd.detail_no = JournalDetail.where(journal_id: jd.journal_id).maximum(:detail_no).to_i + 1
    assert jd.new_record?

    deleted_recipient = donation_recipients(:deleted_one)
    assert deleted_recipient.deleted?
    jd.donation_recipient_id = deleted_recipient.id

    jd.save!
    jd.reload
    assert_nil jd.donation_recipient_id
  end

  def test_new_recordで勘定科目に紐づかない補助科目は自動クリアされる
    source = JournalDetail.find(49649)
    jd = source.dup
    jd.detail_no = JournalDetail.where(journal_id: jd.journal_id).maximum(:detail_no).to_i + 1
    assert jd.new_record?

    other_account = Account.find_by_code(ACCOUNT_CODE_PAID_FEE)
    invalid_sub_account = source.sub_account_id
    assert invalid_sub_account.present?

    jd.account_id = other_account.id
    jd.sub_account_id = invalid_sub_account

    jd.save!
    jd.reload
    assert_equal other_account.id, jd.account_id
    assert_nil jd.sub_account_id
  end

end
