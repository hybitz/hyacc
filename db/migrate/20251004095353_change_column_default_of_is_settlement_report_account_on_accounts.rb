class ChangeColumnDefaultOfIsSettlementReportAccountOnAccounts < ActiveRecord::Migration[6.1]
  def change
    change_column_default :accounts, :is_settlement_report_account, from: true, to: false
  end
end
