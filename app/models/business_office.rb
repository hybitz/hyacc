class BusinessOffice < ApplicationRecord
  belongs_to :company, inverse_of: 'business_offices'
  belongs_to :responsible_person, nostalgic: true, class_name: 'Employee', optional: true

  nostalgic_attr :name
  validates :name, presence: true, uniqueness: {scope: :company_id, case_sensitive: false}

  validates :prefecture_code, presence: true

  before_save :set_prefecture_name

  def address
    [address1, address2].compact.join
  end

  def branches
    company.branches.where(business_office_id: id).map{|b| b.self_and_descendants }.flatten
  end

  def employees(date)
    ret = company.employees.where(['employment_date <= ? and (retirement_date >= ? or retirement_date is null)', date, date])
    ret = ret.joins(:branch_employees).where(branch_employees: {branch_id: branches, default_branch: true})
  end

  private

  def set_prefecture_name
    p = TaxJp::Prefecture.find_by_code(self.prefecture_code)
    self.prefecture_name = p ? p.name : ''
  end
end
