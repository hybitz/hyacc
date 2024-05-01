Rails.application.routes.draw do
  get 'mm', to: 'mm#index'

  namespace :mm do
    resources :accounts do
      collection do
        get 'add_sub_account'
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
    resources :careers

    resources :companies, only: ['index', 'show', 'edit', 'update'] do
      member do
        get 'show_logo'
      end
    end

    resources :customers

    resources :employees do
      collection do
        post 'disable'
      end
      member do
        post 'disable'
      end
    end

    resources :exemptions do
      collection do
        get 'add_dependent_family_member'
      end
    end

    resources :inhabitant_taxes do
      collection do
        post 'confirm'
      end
    end
   
    resources :qualifications
    resources :rents
    resources :skills

    resources :simple_slip_templates do
      collection do
        get 'get_keywords'
        get 'get_sub_accounts'
      end
    end

    resources :users
  end
end
