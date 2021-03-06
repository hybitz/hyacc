require 'test_helper'

class TaxRateValidatorTest < ActiveSupport::TestCase

  def test_非課税
    jh = Journal.new
    jd = jh.journal_details.build(:account => expense_account, :branch => branch, :amount => 100)
    jd.tax_type = TAX_TYPE_NONTAXABLE

    good = [nil, '', 0]
    good.each do |rate|
      jd.tax_rate = rate
      
      assert jd.valid?, jd.errors.full_messages.join("\n")
      assert jd.errors[:tax_rate].empty?
    end
  end

  def test_内税
    jh = Journal.new
    jd = jh.journal_details.build(:account => expense_account, :branch => branch, :amount => 100)
    jd.tax_type = TAX_TYPE_INCLUSIVE

    good = [0.03, 0.05, 0.08]
    good.each do |rate|
      jd.tax_rate = rate
      
      assert jd.valid?, jd.errors.full_messages.join("\n")
      assert jd.errors[:tax_rate].empty?
    end

    bad = [nil, '', 0]
    bad.each do |rate|
      jd.tax_rate = rate
      
      assert jd.invalid?, "#{rate} が有効であること"
      assert jd.errors[:tax_rate].any?
    end
  end
end
