class MigrateDeletedToDisabledOnBusinessOffices < ActiveRecord::Migration[5.2]
  def up
    # 既存のdeleted: trueをdeleted: false, disabled: trueに変更
    BusinessOffice.where(deleted: true).update_all(deleted: false, disabled: true)
  end

  def down
    # ロールバック時はdisabled: trueをdeleted: trueに戻す
    BusinessOffice.where(disabled: true).update_all(deleted: true, disabled: false)
  end
end
