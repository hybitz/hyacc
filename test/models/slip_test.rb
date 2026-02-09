class SlipTest < ActiveSupport::TestCase

  def test_editable?
    slip_finder = Slips::SlipFinder.new(users(:first))
    slip_finder.account_code = ACCOUNT_CODE_CASH
    
    slip = Slips::Slip.new( Journal.find(3), slip_finder )
    assert ! slip.editable?
    
    slip = Slips::Slip.new( Journal.find(4), slip_finder )
    assert slip.editable?

    slip = Slips::Slip.new( Journal.find(5), slip_finder )
    assert ! slip.editable?
  end

end
