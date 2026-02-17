require 'test_helper'
require 'rake'

class InvestmentTaskTest < ActiveSupport::TestCase

  def setup
    Rake.application.rake_require('tasks/investment')
    Rake::Task.define_task(:environment)
  end

  def test_解除対象がある場合に紐付けを解除しメッセージを表示する
    jh = Journal.where.not(slip_type: HyaccConst::SLIP_TYPE_INVESTMENT).first
    inv = Investment.first
    jh.update_column(:investment_id, inv.id)
    assert jh.reload.investment_id.present?

    out, _err = capture_io do
      Rake::Task['hyacc:investment:unlink_non_investment_journals'].invoke
    end

    assert_nil jh.reload.investment_id
    assert_includes out, '有価証券以外の伝票区分で、有価証券に紐づいている伝票が1件あります。紐付けを解除します。'
    assert_includes out, '1件の紐付けを解除しました。'
    assert_includes out, '解除した伝票ID:'
    assert_includes out, jh.id.to_s
  ensure
    Rake::Task['hyacc:investment:unlink_non_investment_journals'].reenable
  end

  def test_解除対象がない場合は対象なしメッセージを表示する
    Journal.where.not(slip_type: HyaccConst::SLIP_TYPE_INVESTMENT).update_all(investment_id: nil)

    out, _err = capture_io do
      Rake::Task['hyacc:investment:unlink_non_investment_journals'].invoke
    end

    assert_includes out, '有価証券以外の伝票区分で、有価証券に紐づいている伝票はありません。'
  ensure
    Rake::Task['hyacc:investment:unlink_non_investment_journals'].reenable
  end

end
