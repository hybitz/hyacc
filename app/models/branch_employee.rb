class BranchEmployee < ActiveRecord::Base
  belongs_to :employee

  def branch
    Branch.get(self.branch_id)
  end
end
