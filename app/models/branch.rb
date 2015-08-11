class Branch < ActiveRecord::Base
  include HyaccConstants
  acts_as_cached :includes => 'branches/branch_cache'
  acts_as_tree :order => 'code'

  belongs_to :company
  has_many :branch_employees
  has_many :employees, :through => :branch_employees
  has_many :sub_branches, :foreign_key=>:parent_id, :class_name=>"Branch", :dependent=>:destroy

  before_save :set_path

  def self.get_branches(company_id, include_deleted=false)
    ret = Branch.where(:company_id => company_id)
    ret = ret.where(:deleted => false) unless include_deleted
    ret
  end

  def parent_name
    return nil unless parent
    parent.name
  end

  private

  def set_path
    nodes = []

    node = self
    while node
      nodes << node
      node = node.parent
    end

    self.path = '/' + nodes.reverse.map{|n| n.id }.join('/')    
  end

end
