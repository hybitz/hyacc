class FinancialStatementHeader < ApplicationRecord
  has_many :financial_statements, dependent: :destroy
end
