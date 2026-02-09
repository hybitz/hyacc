class SimpleSlipSetting < ApplicationRecord
  belongs_to :account

  validates :shortcut_key, format: {with: /\A(Ctrl|Alt)\+[0-9]\z/}
  
end
