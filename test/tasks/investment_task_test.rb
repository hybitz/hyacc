require 'test_helper'
require 'rake'

class InvestmentTaskTest < ActiveSupport::TestCase

  def setup
    Rake.application.rake_require('tasks/investment')
    Rake::Task.define_task(:environment)
  end

  def test_解除対象がある場合に紐付けを解除しメッセージを表示する
    jh = Journal.where.not(slip_type: SLIP_TYPE_INVESTMENT).first
    jh_inv = Journal.where(slip_type: SLIP_TYPE_INVESTMENT).first
    inv = Investment.first
    jh.update_column(:investment_id, inv.id)

    out, _err = capture_io do
      Rake::Task['hyacc:investment:unlink_non_investment_journals'].invoke
    end

    assert_nil jh.reload.investment_id
    assert_equal inv.id, jh_inv.reload.investment_id
    assert_includes out, '有価証券以外の伝票区分で、有価証券に紐づいている伝票が1件あります。紐付けを解除します。'
    assert_includes out, '1件の紐付けを解除しました。'
    assert_includes out, '解除した伝票ID:'
    assert_includes out, jh.id.to_s
    assert_not_includes out, jh_inv.id.to_s
  ensure
    Rake::Task['hyacc:investment:unlink_non_investment_journals'].reenable
  end

  def test_解除対象が複数ある場合に件数と伝票ID一覧が正しく表示される
    journals = Journal.where.not(slip_type: SLIP_TYPE_INVESTMENT).limit(3).to_a
    inv = Investment.first
    journals.each { |jh| jh.update_column(:investment_id, inv.id) }

    out, _err = capture_io do
      Rake::Task['hyacc:investment:unlink_non_investment_journals'].invoke
    end

    journals.each { |jh| assert_nil jh.reload.investment_id }
    assert_includes out, "有価証券以外の伝票区分で、有価証券に紐づいている伝票が#{journals.size}件あります。紐付けを解除します。"
    assert_includes out, "#{journals.size}件の紐付けを解除しました。"
    assert_includes out, '解除した伝票ID:'
    journals.each { |jh| assert_includes out, jh.id.to_s }
  ensure
    Rake::Task['hyacc:investment:unlink_non_investment_journals'].reenable
  end

  def test_解除対象がない場合は対象なしメッセージを表示する
    Journal.where.not(slip_type: SLIP_TYPE_INVESTMENT).update_all(investment_id: nil)

    out, _err = capture_io do
      Rake::Task['hyacc:investment:unlink_non_investment_journals'].invoke
    end

    assert_includes out, '有価証券以外の伝票区分で、有価証券に紐づいている伝票はありません。'
  ensure
    Rake::Task['hyacc:investment:unlink_non_investment_journals'].reenable
  end

end
