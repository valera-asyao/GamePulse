class AddSteamFieldsToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :steam_rating, :float
    add_column :games, :steam_reviews_count, :integer
  end
end
