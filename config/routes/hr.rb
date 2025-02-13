Rails.application.routes.draw do
  get 'hr', to: 'hr#index'

  namespace :hr do
    resources :payrolls do
      collection do
        get 'auto_calc'
        get 'get_branch_employees'
        get 'new_bonus'
      end
      member do
        get 'edit_bonus'
      end
    end

    resources :social_insurances, only: 'index'

    resources :exemptions do
      collection do
        get 'add_dependent_family_member'
      end
    end
  end

end
