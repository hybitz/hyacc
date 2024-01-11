class AddColumnInvoiceIssuerNumberOnCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :invoice_issuer_number, :string
  end
end
