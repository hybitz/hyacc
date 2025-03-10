class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: 'Google'
      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to root_path
    end
  end

end
