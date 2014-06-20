Hyacc::Application.routes.draw do
  resources :assets

  resources :accounts do
    collection do
      get  'add_sub_account'
      get  'list_tree'
      post 'update_tree'
    end
  end

  resources :bank_accounts

  resources :bank_offices, :only => [] do
    collection do
      get 'add_bank_office'
    end
  end
  resources :banks
  resources :business_offices
  resources :careers
  resources :companies, :only => ['index', 'update'] do
    member do
      get 'show_logo'
      get 'edit_logo'
      get 'edit_admin'
      get 'edit_business_type'
    end
  end
  resources :customers do
    collection do
      get 'add_customer_name'
    end
  end
  resources :depreciation_rates
  resources :debt, :only => ['index', 'update']

  resources :employees do
    collection do
      get 'add_branch'
      get 'add_employee_history'
    end
  end

  resources :financial_return_statements, :only => 'index'

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

  resources :inhabitant_taxes
  resources :insurances, :only => 'index'
  resources :pensions, :only => 'index'

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

  resources :tax
  resources :users
  resources :withheld_taxes

  root :to => "notification#index"
  match 'simple/:account_code(/:action(/:id))', :controller=>'simple_slip'
  match ':controller(/:action(/:id(.:format)))'
end
