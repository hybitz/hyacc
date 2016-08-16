require 'sidekiq/web'

Rails.application.routes.draw do

  devise_for :users
  mount Nostalgic::Engine => '/nostalgic', :as => 'nostalgic'

  namespace :mm do
    resources :accounts do
      collection do
        get 'add_sub_account'
        get 'get_tax_type'
        get 'list_tree'
        post 'update_tree'
      end
    end

    resources :bank_accounts

    resources :banks do
      collection do
        get 'add_bank_office'
      end
    end

    resources :branches
    resources :business_offices

    resources :companies, :only => ['index', 'edit', 'update'] do
      member do
        get 'show_logo'
      end
    end

    resources :employees do
      collection do
        get 'add_branch'
      end
      member do
        get 'new_num_of_dependent'
      end
    end

    resources :rents
    resources :users
  end

  namespace :mv do
    resources :depreciation_rates, :only => 'index'
    resources :social_insurances, :only => 'index'
    resources :withheld_taxes, :only => 'index'
  end

  resources :account_transfers, :only => 'index' do
    collection do
      post 'update_details'
    end
  end

  resources :bank_offices, :only => 'index'

  resources :careers
  resources :career_statements, :only => ['index', 'show']
  resources :customers do
    collection do
      get 'add_customer_name'
    end
  end
  resources :deemed_taxes
  resources :debts
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
 
  resources :investments do
    collection do
      get 'not_related'
      get 'relate'
    end
  end

  resources :journals do
    collection do
      get 'add_detail'
      get 'get_account_detail'
      get 'get_allocation'
      get 'get_tax_type'
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

  resources :receipts, :only => 'show'

  resources :simple_slips, :except => 'index' do
    collection do
      get 'get_account_details'
      get 'get_templates'
    end
    member do
      get 'copy'
    end
  end
  get 'simple/:account_code', :to => 'simple_slips#index'

  resources :simple_slip_templates do
    collection do
      get 'get_keywords'
      get 'get_sub_accounts'
    end
  end

  resources :social_expenses, :only => 'index'
  resources :sub_accounts, :only => 'index'
  resources :taxes, :only => ['index', 'update']
  resources :withholding_slip, :only => 'index'

  namespace :bs do
    resources :assets
  end

  resources :investments

  get 'closing', :to => 'closing#index'
  get 'journal_admin', :to => 'journal_admin#index'
  get 'mm', :to => 'mm#index'
  get 'mv', :to => 'mv#index'
  get 'report', :to => 'report#index'
  
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
  
  root 'welcome#index'

end
