class RecommendationsController < ApplicationController
  def index
    @user = current_user
    @recommendations = @user.user_recommendations
                            .includes(game: [:genres, :tags])
                            .order(score: :desc)

    if @recommendations.empty? && @user.interactions.any?
      @recommendations = RecommendationEngine.calculate_for(@user)
    end

    @favorite_genres = @user.favorite_genres.limit(4)
    @interacted_count = @user.interactions.count
  end

  def refresh
    @user = current_user
    RecommendationEngine.calculate_for(@user)

    respond_to do |format|
      format.turbo_stream do
        @recommendations = @user.user_recommendations.includes(game: [:genres, :tags]).order(score: :desc)
        render turbo_stream: turbo_stream.replace("recommendations_container", partial: "recommendations/list", locals: { recommendations: @recommendations })
      end
      format.html { redirect_to recommendations_path, notice: "Рекомендации успешно обновлены!" }
    end
  end
end
