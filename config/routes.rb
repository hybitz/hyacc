# coding: UTF-8
#
# Product: hyacc
# Copyright 2008-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
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

  resources :bank_offices do
    collection do
      get 'add_bank_office'
    end
  end
  resources :banks
  resources :business_offices
  resources :careers
  resources :customers do
    collection do
      get 'add_customer_name'
    end
  end
  resources :depreciation_rates
  resources :debt, :only => ['index', 'update']

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

  resources :inhabitant_taxes
  resources :insurances
  resources :rents
  resources :simple_slip_templates do
    collection do
      get 'get_keywords'
      get 'get_sub_accounts'
    end
  end
  resources :users do
    collection do
      get 'add_simple_slip_setting'
    end
  end
  resources :withheld_taxes

  root :to => "notification#index"
  match 'simple/:account_code(/:action(/:id))', :controller=>'simple_slip'
  match ':controller(/:action(/:id(.:format)))'
end
