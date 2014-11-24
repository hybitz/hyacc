class UpdateSimpleSlipSettings < ActiveRecord::Migration
  def up
    SimpleSlipSetting.find_each do |sss|
      if sss.user_id == 0
        sss.destroy
      end
    end
  end

  def down
  end
end
