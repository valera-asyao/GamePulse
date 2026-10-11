class ProfilesController < ApplicationController
  before_action :set_user

  def show
    @interactions = @user.interactions.includes(game: [ :genres ]).order(updated_at: :desc)
    @rated_games = @interactions.where.not(rating: nil)
    @favorite_games = @interactions.where(favorite: true)
    @top_recommendations = @user.user_recommendations.includes(game: [ :genres ]).order(score: :desc).limit(6)
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Профиль успешно обновлен."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:name, :bio, :avatar_url, :avatar)
  end
end
