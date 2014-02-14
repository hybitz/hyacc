# coding: UTF-8
#
# $Id: branch.rb 2927 2012-09-21 06:55:16Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Branch < ActiveRecord::Base
  include HyaccConstants
  acts_as_cached :includes => 'branches/branch_cache'

  belongs_to :company
  has_many :branches_employees
  has_many :users, :through=>:branches_users
  has_many :employees, :through=>:branches_employees
  has_many :sub_branches, :foreign_key=>:parent_id, :class_name=>"Branch", :dependent=>:destroy
  
  def self.get_branches(company_id, include_deleted=false)
    ret = Branch.where(:company_id => company_id)
    unless include_deleted
      ret = ret.where(:deleted => false)
    end
    ret
  end
  
  def parent
    Branch.get(parent_id)
  end
  
end
