class DependentFamilyMember < ApplicationRecord
  belongs_to :exemption
  validates_presence_of :name, :kana
end
