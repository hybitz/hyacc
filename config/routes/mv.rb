Rails.application.routes.draw do
  namespace :mv do
    resources :depreciation_rates, only: 'index'
    resources :social_insurances, only: 'index'
    resources :employment_insurances, only: 'index'
    resources :withheld_taxes, only: 'index'
  end
end
