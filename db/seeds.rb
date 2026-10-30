puts "=== Seeding Game Recommendation Database ==="

# 1. Genres
genres_data = [
  { name: "RPG", slug: "rpg", description: "Ролевые игры с прокачкой, глубоким сюжетом и выбором" },
  { name: "Экшен", slug: "action", description: "Динамичные игры с боевой системой и реакцией" },
  { name: "Инди", slug: "indie", description: "Авторские проекты независимых разработчиков" },
  { name: "Стратегия", slug: "strategy", description: "Пошаговые и RTS стратегии, тактическое планирование" },
  { name: "Рогалик", slug: "roguelike", description: "Игры с процедурной генерацией и постоянной смертью" },
  { name: "Открытый мир", slug: "open-world", description: "Огромные свободные для исследования миры" },
  { name: "Шутер", slug: "shooter", description: "Стрельба от первого и третьего лица" },
  { name: "Симулятор", slug: "simulator", description: "Симуляторы жизни, управления и техники" },
  { name: "Выживание", slug: "survival", description: "Добыча ресурсов, крафтинг и борьба за жизнь" },
  { name: "Хоррор", slug: "horror", description: "Ужасы, напряженная атмосфера и выживание" },
  { name: "Приключение", slug: "adventure", description: "Сюжетные истории, квесты и исследование" }
]

genres = {}
genres_data.each do |g|
  genres[g[:slug]] = Genre.find_or_create_by!(slug: g[:slug]) do |genre|
    genre.name = g[:name]
    genre.description = g[:description]
  end
end

# 2. Tags
tags_data = %w[
  Киберпанк Фэнтези Сюжет Исследование Сложная Научная-фантастика Пошаговая Уютная Кооператив Ретро
  Мультиплеер Соулслайк Атмосфера Крафтинг Песочница Стелс Головоломка Метроидвания
]
tags = {}
tags_data.each do |t|
  slug = t.downcase
  tags[slug] = Tag.find_or_create_by!(name: t) do |tag|
    tag.slug = slug
  end
end

# 3. Load Games from steam_games.json
games_json_path = Rails.root.join("db/seeds/steam_games.json")
games_data = JSON.parse(File.read(games_json_path), symbolize_names: true)

created_games = {}

games_data.each do |gd|
  game = Game.find_or_initialize_by(slug: gd[:slug])
  game.title = gd[:title]
  game.description = gd[:description]
  game.developer = gd[:developer]
  game.publisher = gd[:publisher]
  game.release_date = Date.parse(gd[:release_date]) rescue Date.new(2020, 1, 1)
  game.platforms = gd[:platforms]
  game.image_url = gd[:image_url]
  game.views_count ||= rand(100..2500)
  game.save!

  # Associate genres
  gd[:genres].each do |g_slug|
    if (genre = genres[g_slug])
      GameGenre.find_or_create_by!(game: game, genre: genre)
    end
  end

  # Associate tags
  gd[:tags].each do |t_slug|
    slug = t_slug.downcase
    tag = tags[slug] || Tag.find_or_create_by!(name: t_slug.capitalize, slug: slug)
    GameTag.find_or_create_by!(game: game, tag: tag)
  end

  created_games[gd[:slug]] = game
end

# 4. Seed Users for collaborative filtering
users_seed = [
  { username: "alex_rpg", email_address: "alex@example.com", name: "Александр (RPG фанат)", bio: "Люблю сюжетные глубокие RPG и фэнтези", avatar_url: "https://api.dicebear.com/7.x/adventurer/svg?seed=Felix&backgroundColor=ffd5dc" },
  { username: "dmitry_action", email_address: "dmitry@example.com", name: "Дмитрий (Хардкорщик)", bio: "Обожаю быстрый экшен, хардкор и соулслайки", avatar_url: "https://api.dicebear.com/7.x/bottts/svg?seed=cyberpunk&backgroundColor=b6e3f4" },
  { username: "elena_indie", email_address: "elena@example.com", name: "Елена (Инди-исследователь)", bio: "Ищу необычные атмосферные игры и рогалики", avatar_url: "https://api.dicebear.com/7.x/adventurer/svg?seed=Zoe&backgroundColor=ffd5dc" },
  { username: "artem_tactics", email_address: "artem@example.com", name: "Артем (Стратег)", bio: "Ценю пошаговые тактики и вдумчивый геймплей", avatar_url: "https://api.dicebear.com/7.x/bottts/svg?seed=mech&backgroundColor=ffdfbf" }
]

seeded_users = {}
users_seed.each do |u_data|
  user = User.find_or_initialize_by(email_address: u_data[:email_address])
  user.username = u_data[:username]
  user.name = u_data[:name]
  user.bio = u_data[:bio]
  user.avatar_url = u_data[:avatar_url]
  user.password = "password123"
  user.save!
  seeded_users[u_data[:username]] = user
end

# 5. Seed Realistic Interactions across genres
interactions_seed = [
  # Alex (RPGs)
  { user: "alex_rpg", game: "the-witcher-3-wild-hunt", rating: 10, liked: true, favorite: true, status: "completed", hours: 160 },
  { user: "alex_rpg", game: "cyberpunk-2077", rating: 9, liked: true, favorite: true, status: "completed", hours: 105 },
  { user: "alex_rpg", game: "baldurs-gate-3", rating: 10, liked: true, favorite: true, status: "completed", hours: 140 },
  { user: "alex_rpg", game: "elden-ring", rating: 9, liked: true, favorite: false, status: "completed", hours: 85 },
  { user: "alex_rpg", game: "disco-elysium", rating: 10, liked: true, favorite: true, status: "completed", hours: 45 },
  { user: "alex_rpg", game: "mass-effect-legendary-edition", rating: 10, liked: true, favorite: true, status: "completed", hours: 110 },
  { user: "alex_rpg", game: "persona-5-royal", rating: 9, liked: true, favorite: true, status: "completed", hours: 90 },
  { user: "alex_rpg", game: "the-elder-scrolls-v-skyrim", rating: 10, liked: true, favorite: true, status: "completed", hours: 250 },
  { user: "alex_rpg", game: "fallout-new-vegas", rating: 10, liked: true, favorite: true, status: "completed", hours: 95 },
  { user: "alex_rpg", game: "dark-souls-iii", rating: 9, liked: true, favorite: false, status: "completed", hours: 70 },
  { user: "alex_rpg", game: "divinity-original-sin-2", rating: 10, liked: true, favorite: true, status: "completed", hours: 115 },
  { user: "alex_rpg", game: "dragon-dogma-2", rating: 8, liked: true, favorite: false, status: "playing", hours: 40 },

  # Dmitry (Action & Souls & Shooters)
  { user: "dmitry_action", game: "elden-ring", rating: 10, liked: true, favorite: true, status: "completed", hours: 220 },
  { user: "dmitry_action", game: "sekiro-shadows-die-twice", rating: 10, liked: true, favorite: true, status: "completed", hours: 110 },
  { user: "dmitry_action", game: "dark-souls-iii", rating: 10, liked: true, favorite: true, status: "completed", hours: 130 },
  { user: "dmitry_action", game: "lies-of-p", rating: 9, liked: true, favorite: true, status: "completed", hours: 60 },
  { user: "dmitry_action", game: "doom-eternal", rating: 10, liked: true, favorite: true, status: "completed", hours: 65 },
  { user: "dmitry_action", game: "dead-cells", rating: 9, liked: true, favorite: true, status: "completed", hours: 140 },
  { user: "dmitry_action", game: "hades", rating: 9, liked: true, favorite: true, status: "completed", hours: 90 },
  { user: "dmitry_action", game: "resident-evil-4-remake", rating: 9, liked: true, favorite: false, status: "completed", hours: 40 },
  { user: "dmitry_action", game: "ultrakill", rating: 10, liked: true, favorite: true, status: "completed", hours: 75 },
  { user: "dmitry_action", game: "ghostrunner", rating: 9, liked: true, favorite: false, status: "completed", hours: 30 },
  { user: "dmitry_action", game: "helldivers-2", rating: 9, liked: true, favorite: true, status: "playing", hours: 95 },
  { user: "dmitry_action", game: "space-marine-2", rating: 9, liked: true, favorite: false, status: "completed", hours: 35 },

  # Elena (Indie, Platformers & Cozy)
  { user: "elena_indie", game: "hades", rating: 10, liked: true, favorite: true, status: "completed", hours: 95 },
  { user: "elena_indie", game: "hollow-knight", rating: 10, liked: true, favorite: true, status: "completed", hours: 85 },
  { user: "elena_indie", game: "stardew-valley", rating: 10, liked: true, favorite: true, status: "playing", hours: 220 },
  { user: "elena_indie", game: "celeste", rating: 10, liked: true, favorite: true, status: "completed", hours: 50 },
  { user: "elena_indie", game: "subnautica", rating: 10, liked: true, favorite: true, status: "completed", hours: 70 },
  { user: "elena_indie", game: "outer-wilds", rating: 10, liked: true, favorite: true, status: "completed", hours: 45 },
  { user: "elena_indie", game: "undertale", rating: 10, liked: true, favorite: true, status: "completed", hours: 30 },
  { user: "elena_indie", game: "balatro", rating: 10, liked: true, favorite: true, status: "playing", hours: 80 },
  { user: "elena_indie", game: "slay-the-spire", rating: 9, liked: true, favorite: true, status: "completed", hours: 110 },
  { user: "elena_indie", game: "dave-the-diver", rating: 9, liked: true, favorite: false, status: "completed", hours: 55 },
  { user: "elena_indie", game: "stray", rating: 9, liked: true, favorite: false, status: "completed", hours: 20 },
  { user: "elena_indie", game: "portal-2", rating: 10, liked: true, favorite: true, status: "completed", hours: 30 },

  # Artem (Strategy, Tactics & Management)
  { user: "artem_tactics", game: "baldurs-gate-3", rating: 10, liked: true, favorite: true, status: "completed", hours: 150 },
  { user: "artem_tactics", game: "civilization-vi", rating: 10, liked: true, favorite: true, status: "playing", hours: 320 },
  { user: "artem_tactics", game: "stellaris", rating: 9, liked: true, favorite: true, status: "playing", hours: 180 },
  { user: "artem_tactics", game: "crusader-kings-iii", rating: 10, liked: true, favorite: true, status: "playing", hours: 160 },
  { user: "artem_tactics", game: "xcom-2", rating: 10, liked: true, favorite: true, status: "completed", hours: 120 },
  { user: "artem_tactics", game: "frostpunk", rating: 9, liked: true, favorite: false, status: "completed", hours: 50 },
  { user: "artem_tactics", game: "manor-lords", rating: 9, liked: true, favorite: true, status: "playing", hours: 70 },
  { user: "artem_tactics", game: "rimworld", rating: 10, liked: true, favorite: true, status: "playing", hours: 260 },
  { user: "artem_tactics", game: "slay-the-spire", rating: 9, liked: true, favorite: false, status: "completed", hours: 85 },
  { user: "artem_tactics", game: "into-the-breach", rating: 10, liked: true, favorite: true, status: "completed", hours: 60 }
]

interactions_seed.each do |is|
  user = seeded_users[is[:user]]
  game = created_games[is[:game]]
  next unless user && game

  interaction = Interaction.find_or_initialize_by(user: user, game: game)
  interaction.rating = is[:rating]
  interaction.liked = is[:liked]
  interaction.favorite = is[:favorite]
  interaction.status = is[:status]
  interaction.hours_played = is[:hours]
  interaction.save!
end

# Update metrics for all games
Game.find_each(&:update_metrics!)

# Calculate initial recommendations for seeded users
seeded_users.each_value do |user|
  RecommendationEngine.calculate_for(user)
end

puts "=== Seeding Completed Successfully! ==="
puts "Created #{Genre.count} genres, #{Tag.count} tags, #{Game.count} games, #{User.count} users, #{Interaction.count} interactions."
