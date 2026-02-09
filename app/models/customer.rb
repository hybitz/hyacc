class Customer < ApplicationRecord
  nostalgic_attr :name, :formal_name, :address

  validates :code, uniqueness: {case_sensitive: false}
  validates :name, presence: true
  validates :formal_name, presence: true

end
