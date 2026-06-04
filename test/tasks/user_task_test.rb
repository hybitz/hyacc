require 'test_helper'
require 'rake'

class UserTaskTest < ActiveSupport::TestCase

  def setup
    Rake.application.rake_require('tasks/user')
    Rake::Task.define_task(:environment)
  end

  def test_無効な従業員に紐づくユーザを論理削除する
    user = User.find(6)
    employee = Employee.find(6)
    assert_not user.deleted?
    assert_not employee.disabled?
    employee.update_column(:disabled, true)

    out, _err = capture_io do
      Rake::Task['hyacc:users:sync_deleted'].invoke
    end

    assert user.reload.deleted?
    assert_includes out, '無効・削除済み従業員に紐づくユーザを論理削除しました: 1 件'
  ensure
    Rake::Task['hyacc:users:sync_deleted'].reenable
  end

  def test_削除済み従業員の無効フラグを補正する
    employee = Employee.find(10)
    assert_not employee.disabled?
    employee.update_columns(deleted: true, disabled: false)

    out, _err = capture_io do
      Rake::Task['hyacc:users:sync_deleted'].invoke
    end

    assert employee.reload.disabled?
    assert_includes out, '削除済み従業員の無効フラグを補正しました: 1 件'
  ensure
    Rake::Task['hyacc:users:sync_deleted'].reenable
  end

  def test_削除済みの管理者ユーザを有効化する
    User.where(admin: true).update_all(deleted: true)
    assert User.where(admin: true, deleted: false).none?

    admin = User.find(2)
    employee = Employee.find(2)

    out, _err = capture_io do
      Rake::Task['hyacc:users:sync_deleted'].invoke
    end

    assert_not admin.reload.deleted?
    assert_not employee.reload.disabled?
    assert_not employee.deleted?
    assert_includes out, '管理者ユーザの削除フラグを補正しました:'
  ensure
    Rake::Task['hyacc:users:sync_deleted'].reenable
  end

  def test_ログイン可能な管理者がいても削除済みの管理者を有効化する
    active_admin = User.find(2)
    deleted_admin = User.find(3)
    assert_not active_admin.deleted?
    deleted_admin.update_column(:deleted, true)

    out, _err = capture_io do
      Rake::Task['hyacc:users:sync_deleted'].invoke
    end

    assert_not active_admin.reload.deleted?
    assert_not deleted_admin.reload.deleted?
    assert_includes out, '管理者ユーザの削除フラグを補正しました: 1 件'
  ensure
    Rake::Task['hyacc:users:sync_deleted'].reenable
  end

  def test_管理者の従業員を有効化する
    admin = User.find(2)
    employee = Employee.find(2)
    assert_not admin.deleted?
    assert_not employee.disabled?
    employee.update_column(:disabled, true)

    out, _err = capture_io do
      Rake::Task['hyacc:users:sync_deleted'].invoke
    end

    assert_not employee.reload.disabled?
    assert_includes out, '管理者の従業員を有効化しました: 1 件'
  ensure
    Rake::Task['hyacc:users:sync_deleted'].reenable
  end

  def test_補正対象がない場合はメッセージを表示する
    assert User.joins(:employee)
               .where(users: { deleted: false }, employees: { disabled: true })
               .none?
    assert Employee.where(deleted: true, disabled: false).none?

    out, _err = capture_io do
      Rake::Task['hyacc:users:sync_deleted'].invoke
    end

    assert_includes out, '補正対象はありませんでした。'
  ensure
    Rake::Task['hyacc:users:sync_deleted'].reenable
  end

end