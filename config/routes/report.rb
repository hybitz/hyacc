Rails.application.routes.draw do
  namespace :report do
    resources :withholding_slip, :only => 'index'
  end
end
