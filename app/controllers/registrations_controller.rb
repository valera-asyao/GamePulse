class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    if authenticated?
      redirect_to root_path, notice: "Вы уже авторизованы."
    else
      @user = User.new
    end
  end

  def create
    @user = User.new(registration_params)
    if @user.save
      start_new_session_for @user
      # Precompute initial recommendations
      RecommendationJob.perform_later(@user.id)
      redirect_to root_path, notice: "Добро пожаловать, #{@user.display_name}! Регистрация прошла успешно."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :username, :name, :bio, :password, :password_confirmation, :avatar_url, :avatar)
  end
end
