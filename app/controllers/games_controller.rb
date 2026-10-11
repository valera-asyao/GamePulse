class GamesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  def index
    @genres = Genre.order(:name)
    @selected_genre = Genre.find_by(slug: params[:genre]) if params[:genre].present?
    @tab = params[:tab] || "all"

    if @tab == "recommended"
      if current_user
        @user_recommendations = current_user.user_recommendations
                                            .includes(game: [:genres, :tags])
                                            .order(score: :desc)

        if @user_recommendations.empty? && current_user.interactions.any?
          RecommendationEngine.calculate_for(current_user)
          @user_recommendations = current_user.user_recommendations
                                              .includes(game: [:genres, :tags])
                                              .order(score: :desc)
        end

        rec_ids = @user_recommendations.map(&:game_id)
        if rec_ids.any?
          @games = Game.includes(:genres, :tags).where(id: rec_ids).in_order_of(:id, rec_ids)
          if @selected_genre
            @games = @games.joins(:genres).where(genres: { id: @selected_genre.id })
          end
        else
          @games = Game.none
        end
      else
        @user_recommendations = []
        @games = Game.none
      end
    else
      scope = Game.includes(:genres, :tags)

      if @selected_genre
        scope = scope.joins(:genres).where(genres: { id: @selected_genre.id })
      end

      if params[:q].present?
        query = "%#{params[:q].strip.downcase}%"
        scope = scope.where("LOWER(games.title) LIKE ? OR LOWER(games.description) LIKE ?", query, query)
      end

      @sort = params[:sort] || "popular"
      @games = case @sort
               when "top_rated"
                 scope.top_rated
               when "recent"
                 scope.recent
               when "title"
                 scope.order(:title)
               else
                 scope.popular
               end

      # Recommendations preview for the homepage
      if current_user
        @user_recommendations = current_user.user_recommendations
                                            .includes(game: [:genres, :tags])
                                            .order(score: :desc)
                                            .limit(6)

        if @user_recommendations.empty? && current_user.interactions.any?
          RecommendationEngine.calculate_for(current_user)
          @user_recommendations = current_user.user_recommendations
                                              .includes(game: [:genres, :tags])
                                              .order(score: :desc)
                                              .limit(6)
        end
      end
    end
  end

  def show
    @game = Game.find_by!(slug: params[:id])
    @game.increment!(:views_count, touch: false)

    if current_user
      @interaction = current_user.interactions.find_or_initialize_by(game: @game)
    end

    @similar_games = @game.similar_games(4)
  end
end
