class DependentFamilyMember < ApplicationRecord
  belongs_to :exemption
  validates_presence_of :name, :kana
  validates :family_sub_type, presence: true, if: -> {exemption_type == 2}
  validates :non_resident_code, presence: true, if: -> {exemption_type == 2 && live_in == false}

  validates_with Validators::NonResidentCodeValidator
  validates_with Validators::ExemptionTypeRestrictionValidator

  before_validation do
    self.non_resident_code = nil if non_resident_code.blank?
    self.family_sub_type   = nil if family_sub_type.blank?
  end
end
