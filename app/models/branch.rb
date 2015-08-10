class Branch < ActiveRecord::Base
  include HyaccConstants
  acts_as_cached :includes => 'branches/branch_cache'
  acts_as_tree :order => 'code'

  belongs_to :company
  has_many :branch_employees
  has_many :employees, :through => :branch_employees
  has_many :sub_branches, :foreign_key=>:parent_id, :class_name=>"Branch", :dependent=>:destroy
  
  def self.get_branches(company_id, include_deleted=false)
    ret = Branch.where(:company_id => company_id)
    unless include_deleted
      ret = ret.where(:deleted => false)
    end
    ret
  end

  def parent_name
    return nil unless parent
    parent.name
  end

end
