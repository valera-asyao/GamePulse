class UiKitController < ApplicationController
  allow_unauthenticated_access only: %i[index]

  def index
    @sample_game = Game.first || Game.new(
      title: "The Witcher 3: Wild Hunt",
      slug: "the-witcher-3-wild-hunt",
      average_rating: 9.3,
      ratings_count: 1420,
      image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/292030/header.jpg"
    )
  end
end
