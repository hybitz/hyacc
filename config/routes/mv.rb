Rails.application.routes.draw do
  mount TaxJp::Engine, at: '/tax_jp', as: 'tax_jp'

  namespace :mv do
    resources :social_insurances, only: 'index'
  end
end
