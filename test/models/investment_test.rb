require 'test_helper'

class InvestmentTest < ActiveSupport::TestCase

  def test_save_購入ではsharesとtrading_valueが正のまま保存される
    investment = Investment.new(investment_params.merge(charges: 0, bank_account_id: bank_account.id))
    investment.save!
    investment.reload
    assert investment.buying?
    assert_equal 20, investment.shares
    assert_equal 100_000, investment.trading_value
  end

  def test_save_売却ではsharesとtrading_valueが正のまま保存される
    investment = Investment.new(
      investment_params.merge(charges: 0, bank_account_id: bank_account.id, buying_or_selling: 0, gains: 0)
    )
    investment.save!
    investment.reload
    assert investment.selling?
    assert_equal 20, investment.shares
    assert_equal 100_000, investment.trading_value
  end

  def test_set_yyyymmdd
    investment = Investment.first
    assert_equal 201503, investment.ym
    assert_equal 1, investment.day

    assert_equal "2015-03-01", investment.yyyymmdd

    investment = Investment.second
    assert_equal 201603, investment.ym
    assert_equal 10, investment.day

    assert_equal "2016-03-10", investment.yyyymmdd
  end

  def test_yyyymmddは形式に合わない値でinvalidになる
    investment = Investment.new(investment_params.merge(charges: 0, bank_account_id: bank_account.id))
    investment.yyyymmdd = '20160230'
    assert_not investment.valid?
    assert investment.errors[:yyyymmdd].any? { |m| m.include?('YYYY-MM-DD 形式') }, investment.errors[:yyyymmdd].inspect
  end

  def test_destroyで紐付くJournalとJournalDetailが物理削除される
    investment = Investment.new(investment_params.merge(charges: 0, bank_account_id: bank_account.id))
    investment.save!

    param = Auto::Journal::InvestmentParam.new(investment, user)
    factory = Auto::Journal::InvestmentFactory.get_instance(param)
    jh = factory.make_journals.first
    jh.investment_id = investment.id
    jh.save!

    journal_id = jh.id
    assert jh.journal_details.reload.any?

    investment.destroy

    assert_nil Journal.find_by(id: journal_id)
    assert_empty JournalDetail.where(journal_id: journal_id)
  end

  def test_3階層の一括登録と連鎖削除
    investment = Investment.new(investment_params.merge(charges: 0, bank_account_id: bank_account.id))
    investment.save!

    param = Auto::Journal::InvestmentParam.new(investment, user)
    factory = Auto::Journal::InvestmentFactory.get_instance(param)
    jh = factory.make_journals.first
    jh.investment_id = investment.id
    jh.save!

    investment_id = investment.id
    journal_id = jh.id
    journal_detail_ids = jh.journal_details.reload.map(&:id)

    assert investment_id.present?
    assert journal_id.present?
    assert journal_detail_ids.any?

    assert_equal investment_id, Journal.find(journal_id).investment_id
    assert_equal journal_id, JournalDetail.where(id: journal_detail_ids).pluck(:journal_id).uniq.first

    investment.destroy

    assert_nil Investment.find_by(id: investment_id)
    assert_nil Journal.find_by(id: journal_id)
    journal_detail_ids.each do |jd_id|
      assert_nil JournalDetail.find_by(id: jd_id)
    end
  end

  def test_有価証券以外の伝票に紐づいているときは削除できない
    investment = Investment.find(2)
    jh = Journal.where.not(slip_type: SLIP_TYPE_INVESTMENT).first
    jh.update_column(:investment_id, investment.id)

    assert_raises(HyaccException) { investment.destroy }
    assert Investment.exists?(investment.id)
  end

end
