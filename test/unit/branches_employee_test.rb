# -*- encoding : utf-8 -*-
#
# $Id: branches_employee_test.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class BranchesEmployeeTest < ActiveRecord::TestCase

  def test_find_by_employee_id
    be = BranchesEmployee.find_by_employee_id(1)
    assert_equal 1, be.branch_id
  end
end
