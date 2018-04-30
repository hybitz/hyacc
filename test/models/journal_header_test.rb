require 'test_helper'

class JournalHeaderTest < ActiveSupport::TestCase

  def test_ym
    jh = JournalHeader.find(1)

    # 年月が未設定は認めない
    jh.ym = nil
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }

    # 年月が空文字列は認めない
    jh.ym = ''
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }

    # 年月は数値6桁しか認めない
    jh.ym = 2007
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }

    # 正常系
    jh.ym = 200706
    assert jh.save!
  end

  def test_day
    jh = JournalHeader.find(1)

    # 日が未設定は認めない
    jh.ym = 200701
    jh.day = nil
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }

    # 日が空文字列は認めない
    jh.ym = 200701
    jh.day = ''
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }

    # 2007年1月は31日まで
    jh.ym = 200701
    jh.day = 31
    assert jh.save!
    jh.day = 32
    assert_raise( ActiveRecord::RecordInvalid ){ jh.save! }
  end

  def test_date=
    expected = Date.new(2018, 1, 20)

    jh = JournalHeader.new
    jh.date = expected
    
    assert_equal 201801, jh.ym
    assert_equal 20, jh.day
  end
  
  def test_find_by_finder_key
    # fixtureで検索キーを設定していないので、ARを一旦保存
    JournalHeader.all.each {|jh| assert jh.save }

    journals = JournalHeader.where('id <= ? and finder_key rlike ?', 10, '.*-8322,[0-9]*,1-.*')
    assert_equal 2, journals.count

    # 検索条件がすべて１つの明細のものでなければヒットしない
    journals = JournalHeader.where('id <= ? and finder_key rlike ?', 10, '.*-8322,[0-9]*,2-.*')
    assert_equal 0, journals.count
  end

  # 貸借の一致しない仕訳の登録がエラーになること
  def test_illegal_dc_amount
    jh = JournalHeader.new
    jh.company_id = 1
    jh.ym = 200906
    jh.day = 8
    jh.remarks = 'テスト'
    jh.create_user_id = 1
    jh.update_user_id = 1
    jh.journal_details << JournalDetail.new
    jh.journal_details[0].detail_no = 1
    jh.journal_details[0].detail_type = DETAIL_TYPE_NORMAL
    jh.journal_details[0].dc_type = DC_TYPE_DEBIT
    jh.journal_details[0].account_id = Account.find_by_code(ACCOUNT_CODE_CASH).id
    jh.journal_details[0].branch_id = Branch.find(1).id
    jh.journal_details[0].amount = 10000
    jh.journal_details << JournalDetail.new
    jh.journal_details[1].detail_no = 1
    jh.journal_details[1].detail_type = DETAIL_TYPE_NORMAL
    jh.journal_details[1].dc_type = DC_TYPE_CREDIT
    jh.journal_details[1].account_id = Account.find_by_code(ACCOUNT_CODE_CASH).id
    jh.journal_details[1].branch_id = Branch.find(1).id
    jh.journal_details[1].amount = 20000

    assert_raise( HyaccException ){ jh.save! }
  end

  # Trac#190
  def test_validate_fiscal_year
    jh = JournalHeader.find(1)

    assert_nothing_raised {
      jh.save!
    }

    jh.ym = 190001

    assert_raise( HyaccException ) {
      jh.save!
    }
  end

  def test_copy
    jh = JournalHeader.find(5880)

    copy = jh.copy
    assert copy.new_record?
    assert_equal jh.ym, copy.ym
    assert_equal jh.day, copy.day
    assert_equal jh.amount, copy.amount
    assert_equal jh.remarks, copy.remarks
    assert_equal jh.slip_type, copy.slip_type
    assert_equal jh.finder_key, copy.finder_key

    if jh.transfer_from_id
      assert_equal jh.transfer_from_id, copy.transfer_from_id
    else
      assert_nil copy.transfer_from_id
    end
      
    assert_equal jh.create_user_id, copy.create_user_id
    assert_equal jh.created_at, copy.created_at
    assert_equal jh.update_user_id, copy.update_user_id
    assert_equal jh.updated_at, copy.updated_at
    assert_equal jh.lock_version, copy.lock_version

    jh.journal_details.each_with_index do |jd, i|
      copy_jd = copy.journal_details[i]
      assert copy_jd.new_record?
      assert_nil copy_jd.journal_header_id
      assert_equal jd.detail_no, copy_jd.detail_no
      assert_equal jd.dc_type, copy_jd.dc_type
      assert_equal jd.account_id, copy_jd.account_id
      assert_equal jd.account_name, copy_jd.account_name

      if jd.sub_account_id
        assert_equal jd.sub_account_id, copy_jd.sub_account_id
        assert_equal jd.sub_account_name, copy_jd.sub_account_name
      else
        assert_nil copy_jd.sub_account_id
        assert_nil copy_jd.sub_account_name
      end

      if jd.social_expense_number_of_people
        assert_equal jd.social_expense_number_of_people, copy_jd.social_expense_number_of_people
      else
        assert_nil copy_jd.social_expense_number_of_people
      end

      assert_equal jd.branch_id, copy_jd.branch_id
      assert_equal jd.amount, copy_jd.amount
      assert_equal jd.detail_type, copy_jd.detail_type
      assert_equal jd.tax_type, copy_jd.tax_type

      if jd.main_detail_id
        assert_equal jd.main_detail_id, copy_jd.main_detail_id
      else
        assert_nil copy_jd.main_detail_id
      end

      assert_equal jd.allocated, copy_jd.allocated
      assert_equal jd.branch_name, copy_jd.branch_name
      assert_equal jd.note, copy_jd.note
      assert_nil copy_jd.created_at
      assert_nil copy_jd.updated_at

      # コピーを編集しても元データに変更はない
      copy_jd.amount += 1
      copy_jd.asset = Asset.new
      assert_equal jd.amount + 1, copy_jd.amount
      assert_not_equal jd.asset, copy_jd.asset
    end
  end

  def test_get_all_related_journals
    journal = JournalHeader.new
    journal.transfer_journals << JournalHeader.new
    journal.transfer_journals[0].transfer_journals << JournalHeader.new
    assert_equal 3, journal.get_all_related_journals.length

    journal.transfer_journals << JournalHeader.new
    assert_equal 4, journal.get_all_related_journals.length
  end

end
