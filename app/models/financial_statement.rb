class FinancialStatement < ActiveRecord::Base
  belongs_to :financial_statement_header;
end
