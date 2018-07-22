require 'test_helper'

# 振替伝票登録時に費用配賦の自動仕訳が正しく作成されているか
class JournalsController::AllocatedCostTest < ActionController::TestCase

  def setup
    sign_in users(:user3)
  end
  
  def test_create_allocated_cost
    post_jh = JournalHeader.new
    post_jh.remarks = '費用配賦テスト' + Time.now.to_s
    post_jh.ym = 200908
    post_jh.day = 13
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = 20 # 福利厚生費
    post_jh.journal_details[0].tax_amount = 4
    post_jh.journal_details[0].input_amount = 100
    post_jh.journal_details[0].tax_type = TAX_TYPE_INCLUSIVE
    post_jh.journal_details[0].tax_rate_percent = 5
    post_jh.journal_details[0].allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2

    assert_difference 'JournalHeader.count', 4 do
      post :create, xhr: true, params: {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.journal_details[0].branch_id,
              :account_id => post_jh.journal_details[0].account_id,
              :tax_amount => post_jh.journal_details[0].tax_amount,
              :input_amount => post_jh.journal_details[0].input_amount,
              :tax_type => post_jh.journal_details[0].tax_type,
              :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
              :allocation_type => post_jh.journal_details[0].allocation_type,
              :dc_type => post_jh.journal_details[0].dc_type
            },
            '2' => {
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :dc_type => post_jh.journal_details[1].dc_type
            }
          }
        }
      },
      :xhr => true

      assert_response :success
      assert_template 'common/reload'
    end
    
    # 仕訳内容の確認
    list = JournalHeader.where(:ym => post_jh.ym, :day => post_jh.day)
    assert_equal 4, list.length, "自動仕訳が３つ作成されるので合計４仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 3, jh.journal_details.length, "消費税明細を含めて３明細"
    assert_equal 0, jh.transfer_journals.length, "内部取引仕訳は費用配賦仕訳に関連付けされる"
    assert_equal 1, jh.journal_details[0].transfer_journals.length
    
    # 自動仕訳（費用配賦）
    auto1 = jh.journal_details[0].transfer_journals[0]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal 4, auto1.journal_details.length, "２部門で４明細"
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200908, auto1.ym
    assert_equal 13, auto1.day
    assert_not_nil auto1.journal_details.find_by_account_id(73), "本社費用配賦の明細がある"
    assert_not_nil auto1.journal_details.find_by_account_id(74), "本社費用負担の明細がある"
    assert_equal 2, auto1.transfer_journals.length
    assert_equal 48, auto1.journal_details[0].amount, "税別で按分して￥４８"
    assert_equal 48, auto1.journal_details[1].amount, "税別で按分して￥４８"
    assert_equal 48, auto1.journal_details[2].amount, "税別で按分して￥４８"
    assert_equal 48, auto1.journal_details[3].amount, "税別で按分して￥４８"
    # 自動仕訳（本支店勘定１）
    auto2 = auto1.transfer_journals[0]
    assert_equal auto1.id, auto2.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto2.slip_type
    assert_not_nil auto2.journal_details.find_by_account_id(71), "支店勘定の明細がある"
    assert_not_nil auto2.journal_details.find_by_account_id(72), "本店勘定の明細がある"
    # 自動仕訳（本支店勘定２）
    auto3 = auto1.transfer_journals[1]
    assert_equal auto1.id, auto3.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto3.slip_type
    assert_not_nil auto3.journal_details.find_by_account_id(71), "支店勘定の明細がある"
    assert_not_nil auto3.journal_details.find_by_account_id(72), "本店勘定の明細がある"
  end
  
  def test_auto_journal_type_prepaid_expense
    remarks = "費用配賦テスト #{Time.now}"
    
    post_jh = JournalHeader.new
    post_jh.remarks = remarks
    post_jh.ym = 200908
    post_jh.day = 14

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account_id = 20 # 福利厚生費
    jd.input_amount = 100
    jd.tax_type = TAX_TYPE_INCLUSIVE
    jd.tax_rate_percent = 5
    jd.tax_amount = 4
    jd.allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
    jd.dc_type = DC_TYPE_DEBIT # 借方
    jd.auto_journal_type = AUTO_JOURNAL_TYPE_PREPAID_EXPENSE

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account_id = 2 # 現金
    jd.input_amount = 100
    jd.tax_type = TAX_TYPE_NONTAXABLE
    jd.dc_type = DC_TYPE_CREDIT # 貸方

    assert_difference 'JournalHeader.count', 6 do
      post :create, xhr: true, params: {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.journal_details[0].branch_id,
              :account_id => post_jh.journal_details[0].account_id,
              :tax_amount => post_jh.journal_details[0].tax_amount,
              :input_amount => post_jh.journal_details[0].input_amount,
              :tax_type => post_jh.journal_details[0].tax_type,
              :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
              :allocation_type => post_jh.journal_details[0].allocation_type,
              :dc_type => post_jh.journal_details[0].dc_type,
              :auto_journal_type => post_jh.journal_details[0].auto_journal_type,
            },
            '2' => {
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :dc_type => post_jh.journal_details[1].dc_type,
            }
          }
        }
      }

      assert_response :success
      assert_template 'common/reload'
    end
    
    # 仕訳内容の確認
    assert @journal = JournalHeader.where(:remarks => remarks).first

    # 自動仕訳（費用配賦）は未払振替伝票の次に作成されるため、配列要素の２番目
    auto1 = @journal.journal_details[0].transfer_journals[1]
    assert_equal @journal.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200909, auto1.ym
    assert_equal 1, auto1.day
  end

  def test_auto_journal_type_accrued_expense
    remarks = 'test_auto_journal_type_accrued_expense' + Time.now.to_s
    
    post_jh = JournalHeader.new
    post_jh.remarks = remarks
    post_jh.ym = 200908
    post_jh.day = 15

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account_id = 20 # 福利厚生費
    jd.tax_amount = 4
    jd.input_amount = 100
    jd.tax_type = TAX_TYPE_INCLUSIVE
    jd.tax_rate_percent = 5
    jd.allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
    jd.dc_type = DC_TYPE_DEBIT # 借方
    jd.auto_journal_type = AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account_id = 2 # 現金
    jd.input_amount = 100
    jd.tax_type = 1
    jd.dc_type = DC_TYPE_CREDIT # 貸方

    assert_difference 'JournalHeader.count', 6 do
      post :create, :xhr => true, :params => {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.journal_details[0].branch_id,
              :account_id => post_jh.journal_details[0].account_id,
              :tax_amount => post_jh.journal_details[0].tax_amount,
              :input_amount => post_jh.journal_details[0].input_amount,
              :tax_type => post_jh.journal_details[0].tax_type,
              :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
              :allocation_type => post_jh.journal_details[0].allocation_type,
              :dc_type => post_jh.journal_details[0].dc_type,
              :auto_journal_type => post_jh.journal_details[0].auto_journal_type
            },
            '2' => {
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :dc_type => post_jh.journal_details[1].dc_type
            }
          }
        }
      }

      assert_response :success
      assert_template 'common/reload'
    end
    
    # 仕訳内容の確認
    assert jh = JournalHeader.where(:remarks => remarks).first

    # 自動仕訳（費用配賦）は前払振替伝票の次に作成されるため、配列要素の２番目
    auto1 = jh.journal_details[0].transfer_journals[1]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200907, auto1.ym
    assert_equal 31, auto1.day
  end

  def test_auto_journal_type_date_input_expense
    remarks = 'test_auto_journal_type_date_input_expense ' + Time.now.to_s
    
    post_jh = JournalHeader.new
    post_jh.remarks = remarks 
    post_jh.ym = 200908
    post_jh.day = 16

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account_id = 20 # 福利厚生費
    jd.tax_amount = 4
    jd.input_amount = 100
    jd.tax_type = TAX_TYPE_INCLUSIVE
    jd.tax_rate_percent = 5
    jd.allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
    jd.dc_type = DC_TYPE_DEBIT # 借方
    jd.auto_journal_type = AUTO_JOURNAL_TYPE_DATE_INPUT_EXPENSE
    jd.auto_journal_year = 2009
    jd.auto_journal_month = 11
    jd.auto_journal_day = 21

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account_id = 2 # 現金
    jd.input_amount = 100
    jd.tax_type = 1
    jd.dc_type = DC_TYPE_CREDIT # 貸方

    assert_difference 'JournalHeader.count', 6 do
      post :create, xhr: true, params: {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.journal_details[0].branch_id,
              :account_id => post_jh.journal_details[0].account_id,
              :tax_amount => post_jh.journal_details[0].tax_amount,
              :input_amount => post_jh.journal_details[0].input_amount,
              :tax_type => post_jh.journal_details[0].tax_type,
              :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
              :allocation_type => post_jh.journal_details[0].allocation_type,
              :dc_type => post_jh.journal_details[0].dc_type,
              :auto_journal_type => post_jh.journal_details[0].auto_journal_type,
              :auto_journal_year => post_jh.journal_details[0].auto_journal_year,
              :auto_journal_month => post_jh.journal_details[0].auto_journal_month,
              :auto_journal_day => post_jh.journal_details[0].auto_journal_day
            },
            '2' => {
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :dc_type => post_jh.journal_details[1].dc_type
            }
          }
        }
      }

      assert_response :success
      assert_template 'common/reload'
    end
    
    # 仕訳内容の確認
    assert jh = JournalHeader.where(:remarks => remarks).first

    # 自動仕訳（費用配賦）は計上日振替伝票の次に作成されるため、配列要素の２番目
    auto1 = jh.journal_details[0].transfer_journals[1]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200911, auto1.ym
    assert_equal 21, auto1.day
  end

  def test_create_allocated_tax_cost
    assert a = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
    assert sa = SubAccount.where(:sub_account_type => SUB_ACCOUNT_TYPE_CORPORATE_TAX, :code => '200').first

    post_jh = JournalHeader.new
    post_jh.remarks = '法人税配賦テスト' + Time.now.to_s
    post_jh.ym = 200911
    post_jh.day = 3
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = a.id
    post_jh.journal_details[0].sub_account_id = sa.id
    post_jh.journal_details[0].settlement_type = SETTLEMENT_TYPE_FULL
    post_jh.journal_details[0].input_amount = 100000
    post_jh.journal_details[0].tax_type = 1
    post_jh.journal_details[0].allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100000
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2

    assert_difference 'JournalHeader.count', 7 do
      post :create, :xhr => true, :params => {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.journal_details[0].branch_id,
              :account_id => post_jh.journal_details[0].account_id,
              :sub_account_id => post_jh.journal_details[0].sub_account_id,
              :settlement_type => post_jh.journal_details[0].settlement_type,
              :input_amount => post_jh.journal_details[0].input_amount,
              :tax_type => post_jh.journal_details[0].tax_type,
              :allocation_type => post_jh.journal_details[0].allocation_type,
              :dc_type => post_jh.journal_details[0].dc_type,
            },
            '2' => {
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :allocation_type => post_jh.journal_details[1].allocation_type,
              :dc_type => post_jh.journal_details[1].dc_type,
            }
          }
        }
      }

      assert_response :success
      assert_template 'common/reload'
    end
    
    # 仕訳内容の確認
    list = JournalHeader.where(:ym => post_jh.ym, :day => post_jh.day)
    
    assert_equal 7, list.length, "自動仕訳が6つ作成されるので合計7仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 2, jh.journal_details.length, "２明細作成"
    assert_equal 1, jh.journal_details[0].transfer_journals.length
    
    # 自動仕訳（配賦）
    auto1 = jh.journal_details[0].transfer_journals[0]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal 4, auto1.journal_details.length, "２部門で４明細"
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_not_nil auto1.journal_details.find_by_account_id(86), "法人税配賦の明細がある"
    assert_not_nil auto1.journal_details.find_by_account_id(87), "法人税負担の明細がある"
  end
  
  
  def test_create_not_allocate_cost
    post_jh = JournalHeader.new
    post_jh.remarks = 'test_create_not_allocate_cost' + Time.now.to_s
    post_jh.ym = 200908
    post_jh.day = 14

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account_id = 20 # 福利厚生費
    jd.tax_amount = 4
    jd.input_amount = 100
    jd.tax_type = TAX_TYPE_INCLUSIVE
    jd.tax_rate_percent = 5
    jd.dc_type = DC_TYPE_DEBIT # 借方

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account_id = 2 # 現金
    jd.input_amount = 100
    jd.tax_type = 1
    jd.dc_type = DC_TYPE_CREDIT # 貸方

    assert_difference 'JournalHeader.count', 1 do
      post :create, xhr: true, params: {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.journal_details[0].branch_id,
              :account_id => post_jh.journal_details[0].account_id,
              :tax_amount => post_jh.journal_details[0].tax_amount,
              :input_amount => post_jh.journal_details[0].input_amount,
              :tax_type => post_jh.journal_details[0].tax_type,
              :tax_rate_percent => post_jh.journal_details[0].tax_rate_percent,
              :allocation_type => post_jh.journal_details[0].allocation_type,
              :dc_type => post_jh.journal_details[0].dc_type
            },
            '2' => {
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :dc_type => post_jh.journal_details[1].dc_type
            }
          }
        }
      }

      assert_response :success
      assert_template 'common/reload'
    end

    # 仕訳内容の確認
    list = JournalHeader.where(:remarks => post_jh.remarks)
    assert_equal 1, list.length, '自動仕訳が作成されない'
    jh = list.first
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 3, jh.journal_details.length, '消費税明細を含めて３明細'
    assert_equal 0, jh.transfer_journals.length
    assert_nil jh.journal_details.find{|jd| jd.transfer_journals.present? }
  end

end
