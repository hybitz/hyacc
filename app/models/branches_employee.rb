# coding: UTF-8
#
# $Id: branches_employee.rb 2928 2012-09-21 07:52:49Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BranchesEmployee < ActiveRecord::Base
  belongs_to :employee

  def branch
    Branch.get(self.branch_id)
  end
end
