require 'test_helper'

class BankOfficeTest < ActiveSupport::TestCase

  def test_新規は有効で登録できる
    office = banks(:without_linked_accounts).bank_offices.build(code: '999', name: '新規支店')
    assert office.valid?
  end

  def test_新規は無効で登録できない
    office = banks(:without_linked_accounts).bank_offices.build(code: '999', name: '新規支店', disabled: true)
    assert office.invalid?
    assert_equal [ERR_BANK_OFFICE_INACTIVE_ON_CREATE], office.errors[:base]
  end

  def test_新規は削除済みで登録できない
    office = banks(:without_linked_accounts).bank_offices.build(code: '999', name: '新規支店', deleted: true)
    assert office.invalid?
    assert_equal [ERR_BANK_OFFICE_INACTIVE_ON_CREATE], office.errors[:base]
  end

end
