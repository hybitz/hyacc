namespace :hyacc do
  namespace :users do

    desc '無効・削除済み従業員に紐づくユーザの deleted フラグを補正する'
    task sync_deleted: :environment do
      messages = []

      ActiveRecord::Base.transaction do
        count = User.where(admin: true, deleted: true).update_all(deleted: false)
        if count.positive?
          messages << "管理者ユーザの削除フラグを補正しました: #{count} 件"
        end

        admin_user_ids = User.where(admin: true).joins(:employee)
                             .where('employees.disabled = ? OR employees.deleted = ?', true, true)
                             .pluck(:id)
        if admin_user_ids.present?
          Employee.where(user_id: admin_user_ids).update_all(disabled: false, deleted: false)
          messages << "管理者の従業員を有効化しました: #{admin_user_ids.size} 件"
        end

        count = Employee.where(deleted: true, disabled: false).update_all(disabled: true)
        if count.positive?
          messages << "削除済み従業員の無効フラグを補正しました: #{count} 件"
        end

        count = User.joins(:employee)
                    .where(deleted: false, employees: { disabled: true })
                    .update_all(deleted: true)
        if count.positive?
          messages << "無効・削除済み従業員に紐づくユーザを論理削除しました: #{count} 件"
        end
      end

      if messages.empty?
        puts '補正対象はありませんでした。'
      else
        messages.each { |message| puts message }
      end
    end

  end
end
