class UpdateAccount3172 < ActiveRecord::Migration
  include HyaccConstants

  def up
    a = Account.find_by_code('3172')
    raise unless a.name == '未払金（取引先）'

    a.transaction do
      a.update_attributes!(
          :name => '未払金（発注先）',
          :sub_account_editable => false,
          :sub_account_type => SUB_ACCOUNT_TYPE_ORDER_PLACEMENT)
    end
  end

  def down
    a = Account.find_by_code('3172')
    raise unless a.name == '未払金（発注先）'

    a.transaction do
      a.update_attributes!(
          :name => '未払金（取引先）',
          :sub_account_editable => true,
          :sub_account_type => SUB_ACCOUNT_TYPE_CUSTOMER)
    end
  end
end
