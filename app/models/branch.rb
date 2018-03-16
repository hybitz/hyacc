class Branch < ApplicationRecord
  acts_as_tree :order => 'code'

  belongs_to :company
  belongs_to :business_office, nostalgic: true, optional: true

  validates :code, presence: true
  validates :formal_name, presence: true

  has_many :branch_employees
  has_many :employees, :through => :branch_employees

  before_save :set_name
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

  def business_office
    super || parent.business_office
  end

  def head_office?
    root?
  end

  private

  def set_name
    self.name = self.formal_name if self.name.blank?
  end
  
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
