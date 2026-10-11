class InteractionsController < ApplicationController
  before_action :set_game

  def create
    @interaction = current_user.interactions.find_or_initialize_by(game: @game)
    update_interaction
  end

  def update
    @interaction = current_user.interactions.find_by!(game: @game)
    update_interaction
  end

  def destroy
    @interaction = current_user.interactions.find_by(game: @game)
    @interaction&.destroy

    respond_to do |format|
      format.turbo_stream do
        @interaction = current_user.interactions.new(game: @game)
        render turbo_stream: turbo_stream.replace("game_interaction_#{@game.id}", partial: "interactions/form", locals: { game: @game, interaction: @interaction })
      end
      format.html { redirect_to @game, notice: "Взаимодействие удалено." }
    end
  end

  private

  def set_game
    @game = Game.find_by!(slug: params[:game_id])
  end

  def update_interaction
    if @interaction.update(interaction_params)
      # Synchronously compute or trigger job
      RecommendationEngine.calculate_for(current_user)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("game_interaction_#{@game.id}", partial: "interactions/form", locals: { game: @game, interaction: @interaction })
        end
        format.html { redirect_to @game, notice: "Ваша оценка и статус сохранены!" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("game_interaction_#{@game.id}", partial: "interactions/form", locals: { game: @game, interaction: @interaction })
        end
        format.html { redirect_to @game, alert: "Не удалось сохранить изменения." }
      end
    end
  end

  def interaction_params
    params.require(:interaction).permit(:rating, :liked, :favorite, :status, :hours_played, :review)
  end
end
