Rails.application.routes.draw do

  devise_for :users

  namespace :mm do
    resources :banks do
      collection do
        get 'add_bank_office'
      end
    end

    resources :branches

    resources :companies, :only => ['index', 'edit', 'update'] do
      member do
        get 'show_logo'
      end
    end
  end

  namespace :mv do
    resources :social_insurances, :only => 'index'
    resources :withheld_taxes, :only => 'index'
  end

  resources :accounts do
    collection do
      get  'add_sub_account'
      get  'list_tree'
      post 'update_tree'
    end
  end

  resources :account_transfers, :only => 'index' do
    collection do
      post 'update_details'
    end
  end

  resources :bank_accounts
  resources :bank_offices, :only => ['index']

  resources :business_offices
  resources :careers
  resources :career_statements, :only => ['index', 'show']
  resources :customers do
    collection do
      get 'add_customer_name'
    end
  end
  resources :deemed_taxes
  resources :depreciation_rates
  resources :debts

  resources :employees do
    collection do
      get 'add_branch'
      get 'add_employee_history'
    end
  end

  resources :exemptions

  resources :financial_return_statements, :only => 'index'
  resources :financial_statements, :only => 'index'
  resources :first_boot, :only => ['index', 'create']

  resources :fiscal_years do
    collection do
      get  'edit_current_fiscal_year'
      post 'update_current_fiscal_year'
    end
    member do
      get  'confirm_carry_forward'
      post 'carry_forward'
    end
  end

  resources :houseworks, :only => 'index' do
    member do
      post 'create_journal'
    end

    resources :housework_details, :except => 'index'
  end

  resources :inhabitant_taxes do
    collection do
      post 'confirm'
    end
  end
  

  resources :journals do
    collection do
      get 'add_detail'
      get 'delete_receipt'
      get 'get_account_detail'
      get 'get_allocation'
      get 'update_tax_type'
    end
    member do
      get 'download_receipt'
    end
  end

  resources :ledgers, :only => ['index', 'show']
  resources :notifications, :only => ['index']
  resources :payrolls do
    collection do
      get 'auto_calc'
      get 'get_branch_employees'
    end
  end

  resources :profiles, :only => ['edit', 'update'] do
    member do
      get 'add_simple_slip_setting'
    end
  end

  resources :rents

  resources :simple_slip_templates do
    collection do
      get 'get_keywords'
      get 'get_sub_accounts'
    end
  end

  resources :social_expenses, :only => ['index']
  resources :sub_accounts, :only => ['index']
  resources :taxes, :only => ['index', 'update']
  resources :users
  resources :withholding_slip, :only => 'index'

  namespace :bs do
    resources :assets
  end

  get 'closing', :to => 'closing#index'
  get 'journal_admin', :to => 'journal_admin#index'
  get 'mm', :to => 'mm#index'
  get 'mv', :to => 'mv#index'
  get 'report', :to => 'report#index'

  get  'simple/:account_code(/:action(/:id))', :controller => 'simple_slip'
  post 'simple/:account_code(/:action(/:id))', :controller => 'simple_slip'

  root 'welcome#index'

end
