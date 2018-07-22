class SimpleSlipSetting < ApplicationRecord
  belongs_to :account

  validates :shortcut_key, :format => {:with => /(Ctrl|Alt)\+[0-9]/}
  
end
