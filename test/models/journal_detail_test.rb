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
end
