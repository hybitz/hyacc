require 'test_helper'

module Auto::Journal
  
  class CarryForwardFactoryTest < ActiveSupport::TestCase
    
    def make_journals
      c = Company.find(3)
      fy = c.get_fiscal_year(2009)
      u = User.find(4)
      factory = AutoJournalFactory.get_instance(CarryForwardParam.new(fy, u))
      jh = factory.make_journals
      
      assert_not_nil jh
      assert_equal 201001, jh.ym
      assert_equal 1, jh.day
      assert_equal SLIP_TYPE_CARRY_FORWARD, jh.slip_type
      assert_equal fy.id, jh.carried_fiscal_year_id
    end
  end
end
