class DependentFamilyMember < ActiveRecord::Base
  belongs_to :exemption
  validates_presence_of :name, :kana
end
