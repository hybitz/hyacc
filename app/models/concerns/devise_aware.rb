module DeviseAware
  extend ActiveSupport::Concern
  
  included do
    if Rails.env.production?
      devise :database_authenticatable,
             :rememberable, :trackable, :validatable,
             :omniauthable, :omniauth_providers => [:google_oauth2]
    else
      devise :database_authenticatable,
             :recoverable, :rememberable, :trackable, :validatable,
             :omniauthable, :omniauth_providers => [:google_oauth2]
    end
  end

end
