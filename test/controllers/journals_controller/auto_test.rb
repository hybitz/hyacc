require 'test_helper'

# 振替伝票登録時に自動仕訳が正しく作成されているか
class JournalsController::AutoTest < ActionController::TestCase

  def setup
    sign_in User.find(3)
  end

  def test_create_head_and_branch
    assert_difference 'JournalHeader.count', 2 do
      post :create, :params => {
        :journal => {
          :ym => 200812,
          :day => 4,
          :remarks => '本支店間取引の自動仕訳テスト',
          :journal_details_attributes => {
            '1' => {
              :dc_type => '1',
              :account_id => '2',
              :branch_id => '1', # 本店
              :input_amount => '1000'
            },
            '2' => {
              :dc_type => '2',
              :account_id => '2',
              :branch_id => '2', # 支店
              :input_amount => '1000'
            }
          }
        }
      },
      :xhr => true

      assert_response :success
      assert_template 'common/reload'
    end

    # 仕訳内容の確認
    list = JournalHeader.where(:ym => 200812, :day => 4)
    assert_equal 2, list.length, "自動仕訳が１つ作成されるので合計２仕訳"
    jh = list[0]
    assert_equal 200812, jh.ym
    assert_equal 4, jh.day
    assert_equal SLIP_TYPE_TRANSFER, jh.slip_type
    assert_equal 1000, jh.amount
    assert_nil jh.transfer_from_id
    assert_nil jh.transfer_from_detail_id
    assert_equal 2, jh.journal_details.size
    assert_equal 1, jh.transfer_journals.size

    # 自動仕訳（支店）
    auto = jh.transfer_journals[0]
    assert_equal 200812, auto.ym
    assert_equal 4, auto.day
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto.slip_type
    assert_equal 1000, auto.amount
    assert_equal jh.id, auto.transfer_from_id
    assert_nil auto.transfer_from_detail_id
    assert_not_nil auto.journal_details.find_by_account_id(71), "支店勘定の明細がある"
    assert_not_nil auto.journal_details.find_by_account_id(72), "本店勘定の明細がある"
  end

  def test_create_branch_and_branch
    remarks = "支店間取引の自動仕訳テスト #{Time.now}"

    assert_difference 'JournalHeader.count', 3 do
      post :create, :params => {
        :journal => {
          :ym => 200812,
          :day => 2,
          :remarks => remarks,
          :journal_details_attributes => {
            '1' => {
              :dc_type => '1',
              :account_id => '2',
              :branch_id => '2', # 支店
              :input_amount => '3000',
            },
            '2' => {
              :dc_type => '2',
              :account_id => '2',
              :branch_id => '3', # 支店
              :input_amount => '3000',
            }
          }
        }
      },
      :xhr => true

      assert_response :success
      assert_template 'common/reload'
    end

    # 仕訳内容の確認
    list = JournalHeader.where(:ym => 200812, :day => 2)
    assert_equal 3, list.length, "自動仕訳が２つ作成されるので合計３仕訳"
    jh = list[0]
    assert_equal remarks, jh.remarks
    assert_equal 3000, jh.amount
    assert_equal 2, jh.journal_details.length
    assert_equal 2, jh.transfer_journals.length

    # 自動仕訳（支店１）
    auto1 = jh.transfer_journals[0]
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto1.slip_type
    assert_equal jh.id, auto1.transfer_from_id
    assert_nil auto1.transfer_from_detail_id
    assert_not_nil auto1.journal_details.find_by_account_id(71), "支店勘定の明細がある"
    assert_not_nil auto1.journal_details.find_by_account_id(72), "本店勘定の明細がある"

    # 自動仕訳（支店２）
    auto2 = jh.transfer_journals[1]
    assert_equal SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, auto2.slip_type
    assert_equal jh.id, auto2.transfer_from_id
    assert_nil auto2.transfer_from_detail_id
    assert_not_nil auto2.journal_details.find_by_account_id(71), "支店勘定の明細がある"
    assert_not_nil auto2.journal_details.find_by_account_id(72), "本店勘定の明細がある"
  end

  def test_create_allocate_assets_of_head_office
    post_jh = JournalHeader.new
    post_jh.remarks = '資産配賦テスト' + Time.now.to_s
    post_jh.ym = 200908
    post_jh.day = 17
    post_jh.lock_version = 0
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = 2 # 現金
    post_jh.journal_details[0].input_amount = 10000
    post_jh.journal_details[0].tax_type = 1
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].sub_account_id = 1 # 北海道銀行
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 5 # 普通預金
    post_jh.journal_details[1].input_amount = 10000
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2
    post_jh.journal_details[1].allocated = true

    assert_difference 'JournalHeader.count', 4 do
      post :create, :params => {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :lock_version => post_jh.lock_version,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.journal_details[0].branch_id,
              :account_id => post_jh.journal_details[0].account_id,
              :input_amount => post_jh.journal_details[0].input_amount,
              :tax_type => post_jh.journal_details[0].tax_type,
              :dc_type => post_jh.journal_details[0].dc_type
            },
            '2' => {
              :sub_account_id => post_jh.journal_details[1].sub_account_id,
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :dc_type => post_jh.journal_details[1].dc_type,
              :allocated => post_jh.journal_details[1].allocated,
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
    assert_equal 2, jh.journal_details.length, "２明細が作成される"
    assert_equal 0, jh.transfer_journals.length, "内部取引伝票は資産配賦伝票に関連付けされる"
    assert_equal 1, jh.journal_details[1].transfer_journals.length

    # 自動仕訳（資産配賦）
    auto1 = jh.journal_details[1].transfer_journals[0]
    assert_equal jh.journal_details[1].id, auto1.transfer_from_detail_id
    assert_equal 2, auto1.transfer_journals.length
    assert_equal 4, auto1.journal_details.length, "２部門で４明細"
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS, auto1.slip_type
    assert_not_nil auto1.journal_details.find_by_account_id(83), "仮資産の明細がある"
    assert_not_nil auto1.journal_details.find_by_account_id(85), "仮負債の明細がある"
    assert_equal 5000, auto1.journal_details[0].amount, "按分して￥５，０００"
    assert_equal 5000, auto1.journal_details[1].amount, "按分して￥５，０００"
    assert_equal 5000, auto1.journal_details[2].amount, "按分して￥５，０００"
    assert_equal 5000, auto1.journal_details[3].amount, "按分して￥５，０００"
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

  def test_create_allocate_assets_of_branch_office
    post_jh = JournalHeader.new
    post_jh.remarks = '資産配賦テスト' + Time.now.to_s
    post_jh.ym = 200908
    post_jh.day = 16
    post_jh.lock_version = 0

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account = Account.find_by_name('消耗品費')
    jd.tax_amount = 476
    jd.input_amount = 10000
    jd.tax_type = TAX_TYPE_INCLUSIVE
    jd.tax_rate_percent = 5
    jd.allocated = true
    jd.dc_type = DC_TYPE_DEBIT # 借方

    jd = post_jh.journal_details.build
    jd.branch_id = 1
    jd.account = Account.find_by_name('小口現金')
    jd.input_amount = 10000
    jd.tax_type = TAX_TYPE_NONTAXABLE
    jd.dc_type = DC_TYPE_CREDIT # 貸方
    jd.allocated = true

    assert_difference 'JournalHeader.count', 7 do
      post :create, :params => {
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
              :allocated => post_jh.journal_details[0].allocated,
              :dc_type => post_jh.journal_details[0].dc_type
            },
            '2' => {
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :dc_type => post_jh.journal_details[1].dc_type,
              :allocated => post_jh.journal_details[1].allocated,
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
    assert_equal 7, list.length, "自動仕訳が6つ作成されるので合計7仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 0, jh.transfer_journals.count, "内部取引の自動仕訳は費用配賦と資産配賦の伝票に関連する"
    assert_equal 3, jh.journal_details.count, "消費税明細を含めて３明細"
    assert_equal 2, jh.journal_details.where(:allocated => true).count
    assert_equal 1, jh.journal_details.where(:allocated => true).first.transfer_journals.count, "費用配賦の自動仕訳が伝票明細に関連する"
    assert_equal 1, jh.journal_details.where(:allocated => true).second.transfer_journals.count, "資産配賦の自動仕訳が伝票明細に関連する"

    # 自動仕訳（費用配賦）
    jd = jh.journal_details.where(:allocated => true).first
    auto = jd.transfer_journals.first
    assert_equal jd.id, auto.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST, auto.slip_type
    assert_equal 2, auto.transfer_journals.size
    assert_equal 4, auto.journal_details.length, "本社に2明細、各部門に1明細ずつ"
    assert_equal 2, auto.journal_details.where(:account_id => 74).size, "本社費用負担の明細がある"
    auto.journal_details.where(:account_id => 74).each do |d|
      assert_equal 4762, d.amount, "按分して￥ 4,762"
    end

    # 自動仕訳（資産配賦）
    jd = jh.journal_details.where(:allocated => true).second
    auto = jd.transfer_journals.first
    assert_equal jd.id, auto.transfer_from_detail_id
    assert_equal SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS, auto.slip_type
    assert_equal 2, auto.transfer_journals.size
    assert_equal 4, auto.journal_details.size, "本社に2明細、各部門に1明細ずつ"
    assert_equal 83, auto.journal_details[0].account_id, "仮資産の明細がある"
    assert_equal post_jh.journal_details[1].branch_id, auto.journal_details[0].branch_id, "配賦対象資産を保有している部門"
    assert_equal 5000, auto.journal_details[0].amount, "按分して￥５，０００"
    assert_equal 85, auto.journal_details[1].account_id, "仮負債の明細がある"
    assert_equal 2, auto.journal_details[1].branch_id, "相手部門"
    assert_equal 32, auto.journal_details[1].sub_account_id, "配賦対象資産を保有している部門"
    assert_equal 5000, auto.journal_details[1].amount, "按分して￥５，０００"
    assert_equal 83, auto.journal_details[2].account_id, "仮資産の明細がある"
    assert_equal post_jh.journal_details[1].branch_id, auto.journal_details[2].branch_id, "配賦対象資産を保有している部門"
    assert_equal 5000, auto.journal_details[2].amount, "按分して￥５，０００"
    assert_equal 85, auto.journal_details[3].account_id, "仮負債の明細がある"
    assert_equal 3, auto.journal_details[3].branch_id, "相手部門"
    assert_equal 32, auto.journal_details[3].sub_account_id, "配賦対象資産を保有している部門"
    assert_equal 5000, auto.journal_details[3].amount, "按分して￥５，０００"
  end

  def test_create_not_allocate_assets
    post_jh = JournalHeader.new
    post_jh.remarks = '費用配賦テスト' + Time.now.to_s
    post_jh.ym = 200908
    post_jh.day = 15
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[0].detail_no = 1
    post_jh.journal_details[0].branch_id = 1
    post_jh.journal_details[0].account_id = 2 # 現金
    post_jh.journal_details[0].input_amount = 10000
    post_jh.journal_details[0].tax_type = 1
    post_jh.journal_details[0].dc_type = DC_TYPE_DEBIT # 借方
    post_jh.journal_details[0].allocated = false
    post_jh.journal_details << JournalDetail.new
    post_jh.journal_details[1].branch_id = 1
    post_jh.journal_details[1].account_id = 5 # 普通預金
    post_jh.journal_details[1].sub_account_id = 1 # 北海道銀行
    post_jh.journal_details[1].input_amount = 10000
    post_jh.journal_details[1].tax_type = 1
    post_jh.journal_details[1].dc_type = DC_TYPE_CREDIT # 貸方
    post_jh.journal_details[1].detail_no = 2
    post_jh.journal_details[1].allocated = false

    assert_difference 'JournalHeader.count', 1 do
      post :create, :params => {
        :journal => {
          :ym => post_jh.ym,
          :day => post_jh.day,
          :remarks => post_jh.remarks,
          :journal_details_attributes => {
            '1' => {
              :branch_id => post_jh.journal_details[0].branch_id,
              :account_id => post_jh.journal_details[0].account_id,
              :input_amount => post_jh.journal_details[0].input_amount,
              :tax_type => post_jh.journal_details[0].tax_type,
              :allocated => post_jh.journal_details[0].allocated,
              :dc_type => post_jh.journal_details[0].dc_type
            },
            '2' => {
              :branch_id => post_jh.journal_details[1].branch_id,
              :account_id => post_jh.journal_details[1].account_id,
              :sub_account_id => post_jh.journal_details[1].sub_account_id,
              :input_amount => post_jh.journal_details[1].input_amount,
              :tax_type => post_jh.journal_details[1].tax_type,
              :dc_type => post_jh.journal_details[1].dc_type,
              :allocated => post_jh.journal_details[1].allocated,
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
    assert_equal 1, list.length, "自動仕訳は作成されないので合計１仕訳"
    jh = list[0]
    assert_equal post_jh.remarks, jh.remarks
    assert_equal post_jh.journal_details[0].input_amount, jh.amount
    assert_equal 2, jh.journal_details.length, "２明細"
    assert_equal 0, jh.transfer_journals.length
  end
end
