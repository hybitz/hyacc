require 'test_helper'

# 振替伝票登録時に費用配賦の自動仕訳が正しく作成されているか
class JournalsController::AllocatedCostTest < ActionController::TestCase

  def setup
    sign_in users(:user3)
  end
  
  def test_費用配賦_子部門に均等
    branch = Branch.find(1)
    assert_equal 2, branch.children.size
    
    post_jh = Journal.new
    post_jh.remarks = '費用配賦_子部門に均等' + SecureRandom.uuid
    post_jh.ym = 200908
    post_jh.day = 13
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].branch = branch
    post_jh.journal_details[0].account_id = 20 # 福利厚生費
    post_jh.journal_details[0].tax_amount = 4
    post_jh.journal_details[0].input_amount = 100
    post_jh.journal_details[0].tax_type = TAX_TYPE_INCLUSIVE
    post_jh.journal_details[0].tax_rate_percent = 5
    post_jh.journal_details[0].allocation_type = ALLOCATION_TYPE_EVEN_BY_CHILDREN
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].branch = branch
    post_jh.journal_details[1].account_id = 2 # 現金
    post_jh.journal_details[1].input_amount = 100
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2

    assert_difference 'Journal.count', 4 do
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
    list = Journal.where(:ym => post_jh.ym, :day => post_jh.day)
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
  
  def test_費用配賦_同列部門に均等
    branch = Branch.find(2)
    assert_equal 1, branch.siblings.size

    post_jh = Journal.new
    post_jh.remarks = '費用配賦_同列部門に均等' + SecureRandom.uuid
    post_jh.ym = 200908
    post_jh.day = 18
    jd = post_jh.journal_details.build
    jd.branch = branch
    jd.account_id = 20 # 福利厚生費
    jd.tax_amount = 4
    jd.input_amount = 100
    jd.tax_type = TAX_TYPE_INCLUSIVE
    jd.tax_rate_percent = 5
    jd.allocation_type = ALLOCATION_TYPE_EVEN_BY_SIBLINGS
    jd.dc_type = DC_TYPE_DEBIT # 借方
    jd = post_jh.journal_details.build
    jd.branch = branch
    jd.account_id = 2 # 現金
    jd.input_amount = 100
    jd.tax_type = TAX_TYPE_NONTAXABLE
    jd.dc_type = DC_TYPE_CREDIT # 貸方
  
    assert_difference 'Journal.count', 4 do
      post :create, xhr: true, params: {
        journal: {
          ym: post_jh.ym,
          day: post_jh.day,
          remarks: post_jh.remarks,
          journal_details_attributes: {
            '1' => {
              branch_id: post_jh.journal_details[0].branch_id,
              account_id: post_jh.journal_details[0].account_id,
              tax_amount: post_jh.journal_details[0].tax_amount,
              input_amount: post_jh.journal_details[0].input_amount,
              tax_type: post_jh.journal_details[0].tax_type,
              tax_rate_percent: post_jh.journal_details[0].tax_rate_percent,
              allocation_type: post_jh.journal_details[0].allocation_type,
              dc_type: post_jh.journal_details[0].dc_type
            },
            '2' => {
              branch_id: post_jh.journal_details[1].branch_id,
              account_id: post_jh.journal_details[1].account_id,
              input_amount: post_jh.journal_details[1].input_amount,
              tax_type: post_jh.journal_details[1].tax_type,
              dc_type: post_jh.journal_details[1].dc_type
            }
          }
        }
      }
  
      assert_response :success
      assert_template 'common/reload'
    end
    
    # 仕訳内容の確認
    list = Journal.where(ym: post_jh.ym, day: post_jh.day)
    assert_equal 4, list.length, "本伝票、配賦仕訳、部門間取引２部門の計４仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 3, jh.journal_details.length, "消費税明細を含めて３明細"
    assert_equal 0, jh.transfer_journals.length
    assert_equal 1, jh.journal_details[0].transfer_journals.length
    assert_equal 0, jh.journal_details[1].transfer_journals.length
    assert_equal 0, jh.journal_details[2].transfer_journals.length
    
    # 自動仕訳（費用配賦）
    auto1 = jh.journal_details[0].transfer_journals[0]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200908, auto1.ym
    assert_equal 18, auto1.day
    assert_not_nil auto1.journal_details.find_by_account_id(73), "本社費用配賦の明細がある"
    assert_not_nil auto1.journal_details.find_by_account_id(74), "本社費用負担の明細がある"
    assert_equal 2, auto1.journal_details.length, "1部門で2明細"
    assert_equal 48, auto1.journal_details[0].amount, auto1.journal_details[0].attributes.to_yaml
    assert_equal 48, auto1.journal_details[1].amount, auto1.journal_details[1].attributes.to_yaml
    assert_equal 2, auto1.transfer_journals.length
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

  def test_費用配賦_前払費用_子部門に均等
    remarks = "費用配賦_前払費用_子部門に均等 #{Time.now}"
    
    post_jh = Journal.new
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

    assert_difference 'Journal.count', 6 do
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
    assert @journal = Journal.where(:remarks => remarks).first

    # 自動仕訳（費用配賦）は未払振替伝票の次に作成されるため、配列要素の２番目
    auto1 = @journal.journal_details[0].transfer_journals[1]
    assert_equal @journal.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200909, auto1.ym
    assert_equal 1, auto1.day
  end

  def test_費用配賦_前払費用_同列部門に均等
    branch = Branch.find(3)
    assert_equal 1, branch.siblings.size

    post_jh = Journal.new
    post_jh.remarks = "費用配賦_前払費用_同列部門に均等 #{Time.now}"
    post_jh.ym = 200908
    post_jh.day = 14
  
    jd = post_jh.journal_details.build
    jd.branch = branch
    jd.account_id = 20 # 福利厚生費
    jd.input_amount = 100
    jd.tax_type = TAX_TYPE_INCLUSIVE
    jd.tax_rate_percent = 5
    jd.tax_amount = 4
    jd.allocation_type = ALLOCATION_TYPE_EVEN_BY_SIBLINGS
    jd.dc_type = DC_TYPE_DEBIT # 借方
    jd.auto_journal_type = AUTO_JOURNAL_TYPE_PREPAID_EXPENSE
  
    jd = post_jh.journal_details.build
    jd.branch = branch
    jd.account_id = 2 # 現金
    jd.input_amount = 100
    jd.tax_type = TAX_TYPE_NONTAXABLE
    jd.dc_type = DC_TYPE_CREDIT # 貸方
  
    assert_difference 'Journal.count', 6 do
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
    list = Journal.where('remarks like ?', JournalUtil.escape_search(post_jh.remarks) + '%')
    assert_equal 6, list.size, "本伝票、前払費用、逆仕訳、配賦、部門間取引２部門の計６仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 3, jh.journal_details.size, "消費税明細を含めて３明細"
    assert_equal 0, jh.transfer_journals.size
    assert_equal 2, jh.journal_details[0].transfer_journals.size
    assert_equal 0, jh.journal_details[1].transfer_journals.size
    assert_equal 0, jh.journal_details[2].transfer_journals.size
    
    # 自動仕訳（前払仕訳）
    auto1 = jh.journal_details[0].transfer_journals[0]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto1.slip_type
    assert_equal 200908, auto1.ym
    assert_equal 31, auto1.day
    assert_equal 2, auto1.journal_details.size
    assert_equal post_jh.journal_details[0].account.code, auto1.journal_details[0].account.code
    assert_equal 96, auto1.journal_details[0].amount, auto1.journal_details[0].attributes.to_yaml
    assert_equal ACCOUNT_CODE_PREPAID_EXPENSE, auto1.journal_details[1].account.code
    assert_equal 96, auto1.journal_details[1].amount, auto1.journal_details[1].attributes.to_yaml
    assert_equal 1, auto1.transfer_journals.size, '逆仕訳が１つ'

    # 自動仕訳（逆仕訳）
    auto2 = auto1.transfer_journals[0]
    assert_equal auto1.id, auto2.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto2.slip_type
    assert_equal 200909, auto2.ym
    assert_equal 1, auto2.day
    assert_equal 2, auto2.journal_details.size
    assert_equal auto1.journal_details[0].account.code, auto2.journal_details[0].account.code
    assert_equal 96, auto2.journal_details[0].amount, auto2.journal_details[0].attributes.to_yaml
    assert_not_equal auto1.journal_details[0].dc_type, auto2.journal_details[0].dc_type
    assert_equal ACCOUNT_CODE_PREPAID_EXPENSE, auto2.journal_details[1].account.code
    assert_equal 96, auto2.journal_details[1].amount, auto2.journal_details[1].attributes.to_yaml
    assert_not_equal auto1.journal_details[1].dc_type, auto2.journal_details[1].dc_type
    assert_equal 0, auto2.transfer_journals.size

    # 自動仕訳（費用配賦）
    auto3 = jh.journal_details[0].transfer_journals[1]
    assert_equal jh.journal_details[0].id, auto3.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto3.slip_type
    assert_equal 200909, auto3.ym
    assert_equal 1, auto3.day
    assert_equal 2, auto3.journal_details.size
    assert_equal ACCOUNT_CODE_SHARED_COST, auto3.journal_details[0].account.code
    assert_equal ACCOUNT_CODE_ALLOCATED_COST, auto3.journal_details[1].account.code
    assert_equal 48, auto3.journal_details[0].amount
    assert_equal 48, auto3.journal_details[1].amount
    assert_equal 2, auto3.transfer_journals.length

    # 自動仕訳（本支店勘定１）
    auto4 = auto3.transfer_journals[0]
    assert_equal auto3.id, auto4.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto4.slip_type
    assert_equal ACCOUNT_CODE_HEAD_OFFICE, auto4.journal_details[0].account.code
    assert_equal ACCOUNT_CODE_BRANCH_OFFICE, auto4.journal_details[1].account.code

    # 自動仕訳（本支店勘定２）
    auto5 = auto3.transfer_journals[1]
    assert_equal auto3.id, auto5.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto5.slip_type
    assert_equal ACCOUNT_CODE_HEAD_OFFICE, auto5.journal_details[0].account.code
    assert_equal ACCOUNT_CODE_BRANCH_OFFICE, auto5.journal_details[1].account.code
  end

  def test_費用配賦_前払費用_人頭割
    branch = Branch.find(1)
    branches = Branch.where(company_id: branch.company_id, deleted: false)
    assert_equal 3, branches.size
    assert_equal 3, BranchEmployee.where(branch_id: branches.select(:id), default_branch: true, deleted: false).size

    post_jh = Journal.new
    post_jh.remarks = "費用配賦_前払費用_人頭割 #{Time.now}"
    post_jh.ym = 200908
    post_jh.day = 21
  
    jd = post_jh.journal_details.build
    jd.branch = branch
    jd.account = Account.find_by_code(ACCOUNT_CODE_SOCIAL_EXPENSE)
    jd.sub_account_id = jd.account.sub_accounts.first.id
    jd.social_expense_number_of_people = 3
    jd.input_amount = 1050
    jd.tax_type = TAX_TYPE_INCLUSIVE
    jd.tax_rate_percent = 5
    jd.tax_amount = 50
    jd.allocation_type = ALLOCATION_TYPE_SHARE_BY_EMPLOYEE
    jd.dc_type = DC_TYPE_DEBIT # 借方
    jd.auto_journal_type = AUTO_JOURNAL_TYPE_PREPAID_EXPENSE
  
    jd = post_jh.journal_details.build
    jd.branch = branch
    jd.account = Account.find_by_code(ACCOUNT_CODE_CASH)
    jd.input_amount = 1050
    jd.tax_type = TAX_TYPE_NONTAXABLE
    jd.dc_type = DC_TYPE_CREDIT # 貸方

    assert_difference 'Journal.count', 6 do
      post :create, xhr: true, params: {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              branch_id: post_jh.journal_details[0].branch_id,
              account_id: post_jh.journal_details[0].account_id,
              sub_account_id: post_jh.journal_details[0].sub_account_id,
              social_expense_number_of_people: post_jh.journal_details[0].social_expense_number_of_people,
              tax_amount: post_jh.journal_details[0].tax_amount,
              input_amount: post_jh.journal_details[0].input_amount,
              tax_type: post_jh.journal_details[0].tax_type,
              tax_rate_percent: post_jh.journal_details[0].tax_rate_percent,
              allocation_type: post_jh.journal_details[0].allocation_type,
              dc_type: post_jh.journal_details[0].dc_type,
              auto_journal_type: post_jh.journal_details[0].auto_journal_type,
            },
            '2' => {
              branch_id: post_jh.journal_details[1].branch_id,
              account_id: post_jh.journal_details[1].account_id,
              input_amount: post_jh.journal_details[1].input_amount,
              tax_type: post_jh.journal_details[1].tax_type,
              dc_type: post_jh.journal_details[1].dc_type,
            }
          }
        }
      }
  
      assert_response :success
      assert_template 'common/reload'
    end
    
    # 仕訳内容の確認
    list = Journal.where('remarks like ?', JournalUtil.escape_search(post_jh.remarks) + '%')
    assert_equal 6, list.size, "本伝票、前払費用、逆仕訳、配賦、部門間取引２部門の計６仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 3, jh.journal_details.size, "消費税明細を含めて３明細"
    assert_equal 0, jh.transfer_journals.size
    assert_equal 2, jh.journal_details[0].transfer_journals.size
    assert_equal 0, jh.journal_details[1].transfer_journals.size
    assert_equal 0, jh.journal_details[2].transfer_journals.size
    
    # 自動仕訳（前払仕訳）
    auto1 = jh.journal_details[0].transfer_journals[0]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto1.slip_type
    assert_equal 200908, auto1.ym
    assert_equal 31, auto1.day
    assert_equal 2, auto1.journal_details.size
    assert_equal post_jh.journal_details[0].account.code, auto1.journal_details[0].account.code
    assert_equal 1000, auto1.journal_details[0].amount
    assert_equal ACCOUNT_CODE_PREPAID_EXPENSE, auto1.journal_details[1].account.code
    assert_equal 1000, auto1.journal_details[1].amount
    assert_equal 1, auto1.transfer_journals.size, '逆仕訳が１つ'
  
    # 自動仕訳（逆仕訳）
    auto2 = auto1.transfer_journals[0]
    assert_equal auto1.id, auto2.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE, auto2.slip_type
    assert_equal 200909, auto2.ym
    assert_equal 1, auto2.day
    assert_equal 2, auto2.journal_details.size
    assert_equal auto1.journal_details[0].account.code, auto2.journal_details[0].account.code
    assert_equal 1000, auto2.journal_details[0].amount
    assert_not_equal auto1.journal_details[0].dc_type, auto2.journal_details[0].dc_type
    assert_equal ACCOUNT_CODE_PREPAID_EXPENSE, auto2.journal_details[1].account.code
    assert_equal 1000, auto2.journal_details[1].amount
    assert_not_equal auto1.journal_details[1].dc_type, auto2.journal_details[1].dc_type
    assert_equal 0, auto2.transfer_journals.size
  
    # 自動仕訳（費用配賦）
    auto3 = jh.journal_details[0].transfer_journals[1]
    assert_equal jh.journal_details[0].id, auto3.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto3.slip_type
    assert_equal 200909, auto3.ym
    assert_equal 1, auto3.day
    assert_equal 4, auto3.journal_details.size
    assert_equal branches.second, auto3.journal_details[0].branch
    assert_equal branches.first, auto3.journal_details[1].branch
    assert_equal branches.third, auto3.journal_details[2].branch
    assert_equal branches.first, auto3.journal_details[3].branch
    assert_equal ACCOUNT_CODE_SHARED_COST, auto3.journal_details[0].account.code
    assert_equal ACCOUNT_CODE_ALLOCATED_COST, auto3.journal_details[1].account.code
    assert_equal ACCOUNT_CODE_SHARED_COST, auto3.journal_details[2].account.code
    assert_equal ACCOUNT_CODE_ALLOCATED_COST, auto3.journal_details[3].account.code
    assert_equal 333, auto3.journal_details[0].amount
    assert_equal 333, auto3.journal_details[1].amount
    assert_equal 333, auto3.journal_details[2].amount
    assert_equal 333, auto3.journal_details[3].amount
    assert_equal 2, auto3.transfer_journals.length
  
    # 自動仕訳（本支店勘定１）
    auto4 = auto3.transfer_journals[0]
    assert_equal auto3.id, auto4.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto4.slip_type
    assert_equal ACCOUNT_CODE_HEAD_OFFICE, auto4.journal_details[0].account.code
    assert_equal ACCOUNT_CODE_BRANCH_OFFICE, auto4.journal_details[1].account.code
  
    # 自動仕訳（本支店勘定２）
    auto5 = auto3.transfer_journals[1]
    assert_equal auto3.id, auto5.transfer_from_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto5.slip_type
    assert_equal ACCOUNT_CODE_HEAD_OFFICE, auto5.journal_details[0].account.code
    assert_equal ACCOUNT_CODE_BRANCH_OFFICE, auto5.journal_details[1].account.code
  end

  def test_auto_journal_type_accrued_expense
    remarks = 'test_auto_journal_type_accrued_expense' + SecureRandom.uuid
    
    post_jh = Journal.new
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

    assert_difference 'Journal.count', 6 do
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
    assert jh = Journal.where(:remarks => remarks).first

    # 自動仕訳（費用配賦）は前払振替伝票の次に作成されるため、配列要素の２番目
    auto1 = jh.journal_details[0].transfer_journals[1]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200907, auto1.ym
    assert_equal 31, auto1.day
  end

  def test_auto_journal_type_date_input_expense
    remarks = 'test_auto_journal_type_date_input_expense ' + SecureRandom.uuid
    
    post_jh = Journal.new
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

    assert_difference 'Journal.count', 6 do
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
    assert jh = Journal.where(:remarks => remarks).first

    # 自動仕訳（費用配賦）は計上日振替伝票の次に作成されるため、配列要素の２番目
    auto1 = jh.journal_details[0].transfer_journals[1]
    assert_equal jh.journal_details[0].id, auto1.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto1.slip_type
    assert_equal 200911, auto1.ym
    assert_equal 21, auto1.day
  end

  def test_create_allocated_tax_cost
    assert a = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
    assert sa = a.get_sub_account_by_code(CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)

    post_jh = Journal.new
    post_jh.remarks = '法人税配賦テスト' + SecureRandom.uuid
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

    assert_difference 'Journal.count', 7 do
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
    list = Journal.where(:ym => post_jh.ym, :day => post_jh.day)
    
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
  
  
  def test_振替伝票の登録_配賦なし
    post_jh = Journal.new
    post_jh.remarks = '振替伝票の登録_配賦なし' + SecureRandom.uuid
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

    assert_difference 'Journal.count', 1 do
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
    list = Journal.where(:remarks => post_jh.remarks)
    assert_equal 1, list.length, '自動仕訳が作成されない'
    jh = list.first
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 3, jh.journal_details.length, '消費税明細を含めて３明細'
    assert_equal 0, jh.transfer_journals.length
    assert_nil jh.journal_details.find{|jd| jd.transfer_journals.present? }
  end

end
