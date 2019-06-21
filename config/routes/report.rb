Rails.application.routes.draw do
  namespace :report do
    resources :employment_insurances, only: ['index']
    resources :ledgers, only: ['index', 'show']
    resources :withholding_slip, only: 'index'
  end
end
