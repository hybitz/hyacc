Rails.application.routes.draw do
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

    resources :companies, :only => ['index', 'edit', 'update'] do
      member do
        get 'show_logo'
      end
    end

    resources :customers

    resources :employees do
      collection do
        get 'add_branch'
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
   
    resources :rents

    resources :simple_slip_templates do
      collection do
        get 'get_keywords'
        get 'get_sub_accounts'
      end
    end

    resources :users
  end
end