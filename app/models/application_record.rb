class ApplicationRecord < ActiveRecord::Base
  include HyaccConst

  self.abstract_class = true
end
