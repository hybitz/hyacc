Rails.application.routes.draw do
  namespace :report do
    resources :ledgers, only: ['index', 'show']
    resources :withholding_slip, only: 'index'
  end
end
