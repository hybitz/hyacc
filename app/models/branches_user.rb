# -*- encoding : utf-8 -*-
#
# $Id: branches_user.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class BranchesUser < ActiveRecord::Base
  belongs_to :branch
  belongs_to :user
end
