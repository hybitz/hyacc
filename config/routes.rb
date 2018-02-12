require 'sidekiq/web'

Rails.application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth_callbacks' }
  mount Nostalgic::Engine => '/nostalgic', :as => 'nostalgic'

  resources :accounts
  resources :bank_offices, :only => 'index'
  resources :careers
  resources :career_statements, :only => ['index', 'show']
  resources :deemed_taxes
  resources :debts
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

  resources :social_expenses, :only => 'index'
  resources :sub_accounts, :only => 'index'
  resources :taxes, :only => ['index', 'update']

  namespace :bs do
    resources :assets
  end

  get 'closing', :to => 'closing#index'
  get 'journal_admin', :to => 'journal_admin#index'
  get 'mv', :to => 'mv#index'
  get 'report', :to => 'report#index'
  
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end
  
  root 'welcome#index'

end
