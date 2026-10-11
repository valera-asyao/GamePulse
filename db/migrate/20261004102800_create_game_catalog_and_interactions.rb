class CreateGameCatalogAndInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :genres do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description

      t.timestamps
    end
    add_index :genres, :slug, unique: true

    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end
    add_index :tags, :slug, unique: true

    create_table :games do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.string :developer
      t.string :publisher
      t.date :release_date
      t.string :platforms
      t.string :image_url
      t.string :banner_url
      t.float :average_rating, default: 0.0
      t.integer :ratings_count, default: 0
      t.integer :views_count, default: 0
      t.float :popularity_score, default: 0.0

      t.timestamps
    end
    add_index :games, :slug, unique: true
    add_index :games, :average_rating
    add_index :games, :popularity_score

    create_table :game_genres do |t|
      t.references :game, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true

      t.timestamps
    end
    add_index :game_genres, [:game_id, :genre_id], unique: true

    create_table :game_tags do |t|
      t.references :game, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
    add_index :game_tags, [:game_id, :tag_id], unique: true

    create_table :interactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.integer :rating
      t.boolean :liked, default: false, null: false
      t.boolean :favorite, default: false, null: false
      t.string :status, default: "none"
      t.integer :hours_played, default: 0
      t.text :review
      t.integer :view_count, default: 0

      t.timestamps
    end
    add_index :interactions, [:user_id, :game_id], unique: true
    add_index :interactions, :rating
    add_index :interactions, :liked
    add_index :interactions, :favorite

    create_table :user_recommendations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.float :score, default: 0.0, null: false
      t.float :genre_score, default: 0.0
      t.float :collaborative_score, default: 0.0
      t.float :popularity_score, default: 0.0
      t.float :recency_score, default: 0.0
      t.string :reason

      t.timestamps
    end
    add_index :user_recommendations, [:user_id, :game_id], unique: true
    add_index :user_recommendations, [:user_id, :score]
  end
end
