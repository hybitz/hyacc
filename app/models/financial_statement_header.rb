class FinancialStatementHeader < ActiveRecord::Base
  has_many :financial_statements, dependent: :destroy
end
