class Housework < ActiveRecord::Base
  has_many :details, :class_name => 'HouseworkDetail', :dependent => :destroy
  has_many :journal_headers, :dependent=>:destroy
  validates_presence_of :fiscal_year
  accepts_nested_attributes_for :journal_headers
end
