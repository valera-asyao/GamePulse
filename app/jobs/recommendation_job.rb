class RecommendationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    RecommendationEngine.calculate_for(user)
  end
end
