# -*- encoding : utf-8 -*-
#
# $Id: slip_test.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class SlipTest < ActiveSupport::TestCase
  include HyaccConstants

  def test_editable?
    slip_finder = Slips::SlipFinder.new(users(:first))
    slip_finder.account_code = ACCOUNT_CODE_CASH
    
    slip = Slips::Slip.new( JournalHeader.find(3), slip_finder )
    assert ! slip.editable?
    
    slip = Slips::Slip.new( JournalHeader.find(4), slip_finder )
    assert slip.editable?

    slip = Slips::Slip.new( JournalHeader.find(5), slip_finder )
    assert ! slip.editable?
  end
end
