# -*- encoding : utf-8 -*-
# 支店勘定と本社費用配賦に部門を補助科目として登録
class UpdateSubAccounts < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    branches = Branch.find(:all)
  
    account_branch_office = Account.find_by_code( ACCOUNT_CODE_BRANCH_OFFICE )
    update_sub_accounts( account_branch_office, branches )
    
    account_head_office_cost = Account.find_by_code( ACCOUNT_CODE_HEAD_OFFICE_COST )
    update_sub_accounts( account_head_office_cost, branches )
  end

  def self.down
  end
  
  def self.update_sub_accounts( account, branches )
    account.sub_accounts.clear

    branches.each {|branch|
      next if branch.is_head_office
      
      sub_account = SubAccount.new
      sub_account.code = branch.code
      sub_account.name = branch.name
      account.sub_accounts << sub_account
    }

    account.save!
  end
end
