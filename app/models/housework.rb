class Housework < ApplicationRecord
  validates :fiscal_year, :presence => true
  has_many :details, :class_name => 'HouseworkDetail', :dependent => :destroy
  has_many :journal_headers, :dependent => :destroy
  accepts_nested_attributes_for :journal_headers
end
