class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 15, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Слишком много попыток. Пожалуйста, попробуйте позже." }

  def new
    if authenticated?
      redirect_to root_path, notice: "Вы уже вошли в систему."
    end
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url, notice: "С возвращением, #{user.display_name}!"
    else
      redirect_to new_session_path, alert: "Неверный адрес электронной почты или пароль."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Вы вышли из системы.", status: :see_other
  end
end
