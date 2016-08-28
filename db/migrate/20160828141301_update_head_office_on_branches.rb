class UpdateHeadOfficeOnBranches < ActiveRecord::Migration
  def up
    Company.find_each do |c|
      head = Branch.where(:company_id => c.id).where('parent_id is null').first
      head_office = BusinessOffice.where(:company_id => c.id, :is_head => true).first
      head.update_attributes!(:business_office_id => head_office.id)
    end
  end
  def down
  end
end
