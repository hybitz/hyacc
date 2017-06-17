class BranchEmployee < ApplicationRecord
  belongs_to :branch
  belongs_to :employee
end
