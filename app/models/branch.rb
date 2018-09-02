class Branch < ApplicationRecord
  acts_as_tree order: 'code'

  belongs_to :company
  belongs_to :business_office, nostalgic: true, optional: true

  validates :code, presence: true
  validates :formal_name, presence: true

  has_many :branch_employees, -> { where deleted: false }
  has_many :employees, through: :branch_employees

  before_save :set_name
  before_save :set_path

  def self.get_branches(company_id, include_deleted=false)
    ret = Branch.where(:company_id => company_id)
    ret = ret.where(:deleted => false) unless include_deleted
    ret
  end

  def parent_name
    parent.try(:name)
  end

  def children
    super.where(deleted: false)
  end

  def business_office
    super || parent.business_office
  end

  def business_office_at(date)
    business_office_id = business_office_id_at(date) || parent.business_office_id_at(date)
    BusinessOffice.find_by_id(business_office_id)
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
