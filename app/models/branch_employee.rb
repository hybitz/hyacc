class BranchEmployee < ActiveRecord::Base
  belongs_to :branch
  belongs_to :employee
end
