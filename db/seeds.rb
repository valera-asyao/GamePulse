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
  { name: "Симулятор", slug: "simulator", description: "Симуляторы фермы, жизни и управления" }
]

genres = {}
genres_data.each do |g|
  genres[g[:slug]] = Genre.find_or_create_by!(slug: g[:slug]) do |genre|
    genre.name = g[:name]
    genre.description = g[:description]
  end
end

# 2. Tags
tags_data = %w[Киберпанк Фэнтези Сюжет Исследование Сложная Научная-фантастика Пошаговая Уютная Кооператив Ретро]
tags = {}
tags_data.each do |t|
  slug = t.downcase
  tags[slug] = Tag.find_or_create_by!(name: t) do |tag|
    tag.slug = slug
  end
end

# 3. Games
games_data = [
  {
    title: "The Witcher 3: Wild Hunt",
    slug: "the-witcher-3-wild-hunt",
    description: "Культовая сюжетная ролевая игра о ведьмаке Геральте из Ривии в мрачном фэнтезийном открытом мире.",
    developer: "CD Projekt RED",
    publisher: "CD Projekt",
    release_date: Date.new(2015, 5, 19),
    platforms: "PC, PlayStation 5, Xbox Series X, Nintendo Switch",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/292030/header.jpg",
    genres: %w[rpg open-world action],
    tags: %w[фэнтези сюжет исследование]
  },
  {
    title: "Cyberpunk 2077",
    slug: "cyberpunk-2077",
    description: "Приключенческая ролевая игра в открытом мире Найт-Сити, где власть, роскошь и модификации тела ценятся выше всего.",
    developer: "CD Projekt RED",
    publisher: "CD Projekt",
    release_date: Date.new(2020, 12, 10),
    platforms: "PC, PlayStation 5, Xbox Series X",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg",
    genres: %w[rpg open-world shooter],
    tags: %w[киберпанк сюжет научная-фантастика]
  },
  {
    title: "Baldur's Gate 3",
    slug: "baldurs-gate-3",
    description: "Грандиозная партийная ролевая игра нового поколения по правилам D&D с беспрецедентной свободой выбора.",
    developer: "Larian Studios",
    publisher: "Larian Studios",
    release_date: Date.new(2023, 8, 3),
    platforms: "PC, PlayStation 5, Xbox Series X",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/1086940/header.jpg",
    genres: %w[rpg strategy],
    tags: %w[фэнтези сюжет сложная кооператив]
  },
  {
    title: "Elden Ring",
    slug: "elden-ring",
    description: "Хардкорный ролевой боевик в таинственном Междуземье, созданном Хидэтакой Миядзаки и Джорджем Р. Р. Мартином.",
    developer: "FromSoftware",
    publisher: "Bandai Namco",
    release_date: Date.new(2022, 2, 25),
    platforms: "PC, PlayStation 5, Xbox Series X",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/1245620/header.jpg",
    genres: %w[rpg action open-world],
    tags: %w[фэнтези сложная исследование]
  },
  {
    title: "Hades",
    slug: "hades",
    description: "Динамичный rogue-like экшен, в котором вам предстоит с боем вырваться из владений самого бога подземного мира.",
    developer: "Supergiant Games",
    publisher: "Supergiant Games",
    release_date: Date.new(2020, 9, 17),
    platforms: "PC, PlayStation, Xbox, Switch, iOS",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/1145360/header.jpg",
    genres: %w[indie roguelike action],
    tags: %w[фэнтези сложная сюжет]
  },
  {
    title: "Hollow Knight",
    slug: "hollow-knight",
    description: "Атмосферное двухмерное приключение в забытом королевстве насекомых и героев, полное тайн и испытаний.",
    developer: "Team Cherry",
    publisher: "Team Cherry",
    release_date: Date.new(2017, 2, 24),
    platforms: "PC, PlayStation, Xbox, Nintendo Switch",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/367520/header.jpg",
    genres: %w[indie action],
    tags: %w[исследование сложная сюжет ретро]
  },
  {
    title: "Red Dead Redemption 2",
    slug: "red-dead-redemption-2",
    description: "Эпическая драма о банде Датча ван дер Линде на закате эпохи Дикого Запада с непревзойденной проработкой мира.",
    developer: "Rockstar Games",
    publisher: "Rockstar Games",
    release_date: Date.new(2018, 10, 26),
    platforms: "PC, PlayStation 4, Xbox One",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/1174180/header.jpg",
    genres: %w[action open-world],
    tags: %w[сюжет исследование]
  },
  {
    title: "Stardew Valley",
    slug: "stardew-valley",
    description: "Уютный и глубокий симулятор сельской жизни: восстановите заброшенную ферму дедушки и заведите друзей.",
    developer: "ConcernedApe",
    publisher: "ConcernedApe",
    release_date: Date.new(2016, 2, 26),
    platforms: "PC, Consoles, Mobile",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/413150/header.jpg",
    genres: %w[indie simulator rpg],
    tags: %w[уютная кооператив ретро]
  },
  {
    title: "Sid Meier's Civilization VI",
    slug: "civilization-vi",
    description: "Легендарная пошаговая стратегия: постройте цивилизацию, способную выдержать испытание временем.",
    developer: "Firaxis Games",
    publisher: "2K Games",
    release_date: Date.new(2016, 10, 21),
    platforms: "PC, Consoles, iPad",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/289070/header.jpg",
    genres: %w[strategy],
    tags: %w[пошаговая сложная]
  },
  {
    title: "DOOM Eternal",
    slug: "doom-eternal",
    description: "Невероятно быстрый и адреналиновый шутер: крушите орды демонов во всевозможных измерениях.",
    developer: "id Software",
    publisher: "Bethesda Softworks",
    release_date: Date.new(2020, 3, 20),
    platforms: "PC, PlayStation, Xbox, Switch",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/782330/header.jpg",
    genres: %w[action shooter],
    tags: %w[сложная научная-фантастика]
  },
  {
    title: "Disco Elysium - The Final Cut",
    slug: "disco-elysium",
    description: "Революционная детективная изометрическая RPG с уникальной системой диалогов и моральных выборов.",
    developer: "ZA/UM",
    publisher: "ZA/UM",
    release_date: Date.new(2019, 10, 15),
    platforms: "PC, PlayStation, Xbox, Switch",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/632470/header.jpg",
    genres: %w[rpg indie],
    tags: %w[сюжет исследование]
  },
  {
    title: "Portal 2",
    slug: "portal-2",
    description: "Гениальная головоломка от Valve с непревзойденным черным юмором, физикой порталов и совместным режимом.",
    developer: "Valve",
    publisher: "Valve",
    release_date: Date.new(2011, 4, 19),
    platforms: "PC, Consoles, Nintendo Switch",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/620/header.jpg",
    genres: %w[action indie],
    tags: %w[научная-фантастика кооператив сюжет]
  },
  {
    title: "God of War",
    slug: "god-of-war",
    description: "Кратос и его сын Атрей отправляются в опасное путешествие по скандинавским мифам, сражаясь с богами и чудовищами.",
    developer: "Santa Monica Studio",
    publisher: "PlayStation Publishing",
    release_date: Date.new(2018, 4, 20),
    platforms: "PC, PlayStation 4, PlayStation 5",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/1593500/header.jpg",
    genres: %w[action rpg open-world],
    tags: %w[фэнтези сюжет сложная]
  },
  {
    title: "Grand Theft Auto V",
    slug: "grand-theft-auto-v",
    description: "Культовый криминальный боевик об ограблениях в солнечном Лос-Сантосе с тремя неповторимыми главными героями.",
    developer: "Rockstar North",
    publisher: "Rockstar Games",
    release_date: Date.new(2013, 9, 17),
    platforms: "PC, PlayStation, Xbox",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/271590/header.jpg",
    genres: %w[action open-world shooter],
    tags: %w[сюжет исследование кооператив]
  },
  {
    title: "Persona 5 Royal",
    slug: "persona-5-royal",
    description: "Стильная японская RPG о Призрачных Похитителях Сердец, меняющих сердца испорченных людей в современном Токио.",
    developer: "ATLUS",
    publisher: "SEGA",
    release_date: Date.new(2020, 3, 31),
    platforms: "PC, PlayStation, Xbox, Nintendo Switch",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/1687950/header.jpg",
    genres: %w[rpg strategy],
    tags: %w[пошаговая сюжет уютная]
  },
  {
    title: "Celeste",
    slug: "celeste",
    description: "Трогательный и филигранный платформер о восхождении на загадочную гору Селеста и победе над внутренними сомнениями.",
    developer: "Maddy Makes Games",
    publisher: "Maddy Makes Games",
    release_date: Date.new(2018, 1, 25),
    platforms: "PC, Nintendo Switch, PlayStation, Xbox",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/504230/header.jpg",
    genres: %w[indie action],
    tags: %w[сложная сюжет ретро уютная]
  },
  {
    title: "Forza Horizon 5",
    slug: "forza-horizon-5",
    description: "Красочный праздник автоспорта в захватывающей Мексике с огромным открытым миром и сотнями детальных суперкаров.",
    developer: "Playground Games",
    publisher: "Xbox Game Studios",
    release_date: Date.new(2021, 11, 9),
    platforms: "PC, Xbox Series X|S, Xbox One",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/1551360/header.jpg",
    genres: %w[simulator open-world],
    tags: %w[исследование кооператив]
  },
  {
    title: "Sekiro: Shadows Die Twice",
    slug: "sekiro-shadows-die-twice",
    description: "Бескомпромиссный ролевой боевик о верном синоби Одноруком Волке в феодальной Японии с непревзойденной дуэльной боевкой.",
    developer: "FromSoftware",
    publisher: "Activision",
    release_date: Date.new(2019, 3, 22),
    platforms: "PC, PlayStation 4, Xbox One",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/814380/header.jpg",
    genres: %w[action rpg],
    tags: %w[сложная фэнтези сюжет]
  },
  {
    title: "Dead Cells",
    slug: "dead-cells",
    description: "Бешеный rogue-lite экшен-платформер с процедурно генерируемым замком, десятками видов оружия и стремительными боями.",
    developer: "Motion Twin",
    publisher: "Motion Twin",
    release_date: Date.new(2018, 8, 7),
    platforms: "PC, Consoles, Mobile",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/588650/header.jpg",
    genres: %w[indie roguelike action],
    tags: %w[сложная ретро исследование]
  },
  {
    title: "Mass Effect Legendary Edition",
    slug: "mass-effect-legendary-edition",
    description: "Великая научно-фантастическая сага о капитане Шепарде и спасении галактики от древних разумных машин.",
    developer: "BioWare",
    publisher: "Electronic Arts",
    release_date: Date.new(2021, 5, 14),
    platforms: "PC, PlayStation, Xbox",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/1328670/header.jpg",
    genres: %w[rpg shooter action],
    tags: %w[научная-фантастика сюжет исследование]
  },
  {
    title: "Subnautica",
    slug: "subnautica",
    description: "Атмосферное приключение на неизведанной водной планете: погружайтесь на невиданные глубины и стройте базы.",
    developer: "Unknown Worlds",
    publisher: "Unknown Worlds",
    release_date: Date.new(2018, 1, 23),
    platforms: "PC, PlayStation, Xbox, Switch",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/264710/header.jpg",
    genres: %w[indie simulator open-world],
    tags: %w[научная-фантастика исследование сюжет]
  },
  {
    title: "Resident Evil 4 Remake",
    slug: "resident-evil-4-remake",
    description: "Блестящее переосмысление эталонного экшен-хоррора: Леон Кеннеди пробивается сквозь кошмар испанской глуши.",
    developer: "Capcom",
    publisher: "Capcom",
    release_date: Date.new(2023, 3, 24),
    platforms: "PC, PlayStation 5, Xbox Series X",
    image_url: "https://shared.steamstatic.com/store_item_assets/steam/apps/2050650/header.jpg",
    genres: %w[action shooter],
    tags: %w[сложная сюжет]
  },
  {
    title: "Minecraft",
    slug: "minecraft",
    description: "Культовая бесконечная песочница: исследуйте процедурные миры, добывайте ресурсы и творите без ограничений.",
    developer: "Mojang Studios",
    publisher: "Xbox Game Studios",
    release_date: Date.new(2011, 11, 18),
    platforms: "PC, Consoles, Mobile",
    image_url: "https://images.igdb.com/igdb/image/upload/t_720p/co49x5.jpg",
    genres: %w[indie simulator open-world],
    tags: %w[уютная кооператив исследование]
  }
]

created_games = {}
games_data.each do |gd|
  game = Game.find_or_initialize_by(slug: gd[:slug])
  game.title = gd[:title]
  game.description = gd[:description]
  game.developer = gd[:developer]
  game.publisher = gd[:publisher]
  game.release_date = gd[:release_date]
  game.platforms = gd[:platforms]
  game.image_url = gd[:image_url]
  game.views_count = rand(100..1200)
  game.save!

  # Associate genres
  gd[:genres].each do |g_slug|
    if genre = genres[g_slug]
      GameGenre.find_or_create_by!(game: game, genre: genre)
    end
  end

  # Associate tags
  gd[:tags].each do |t_slug|
    if tag = tags[t_slug]
      GameTag.find_or_create_by!(game: game, tag: tag)
    end
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

# 5. Seed Interactions (Ratings, Likes, Favorites)
interactions_seed = [
  # Alex (likes RPGs): Witcher 3, Cyberpunk, Baldur's Gate 3, Elden Ring, Mass Effect, Persona 5
  { user: "alex_rpg", game: "the-witcher-3-wild-hunt", rating: 10, liked: true, favorite: true, status: "completed", hours: 150 },
  { user: "alex_rpg", game: "cyberpunk-2077", rating: 9, liked: true, favorite: true, status: "completed", hours: 95 },
  { user: "alex_rpg", game: "baldurs-gate-3", rating: 10, liked: true, favorite: true, status: "playing", hours: 120 },
  { user: "alex_rpg", game: "elden-ring", rating: 9, liked: true, favorite: false, status: "completed", hours: 80 },
  { user: "alex_rpg", game: "disco-elysium", rating: 9, liked: true, favorite: true, status: "completed", hours: 40 },
  { user: "alex_rpg", game: "mass-effect-legendary-edition", rating: 10, liked: true, favorite: true, status: "completed", hours: 110 },
  { user: "alex_rpg", game: "persona-5-royal", rating: 9, liked: true, favorite: true, status: "playing", hours: 85 },
  { user: "alex_rpg", game: "god-of-war", rating: 9, liked: true, favorite: false, status: "completed", hours: 45 },

  # Dmitry (likes Souls & fast Action): Elden Ring, DOOM, Sekiro, Dead Cells, RE4, GTA V
  { user: "dmitry_action", game: "elden-ring", rating: 10, liked: true, favorite: true, status: "completed", hours: 210 },
  { user: "dmitry_action", game: "doom-eternal", rating: 10, liked: true, favorite: true, status: "completed", hours: 55 },
  { user: "dmitry_action", game: "sekiro-shadows-die-twice", rating: 10, liked: true, favorite: true, status: "completed", hours: 95 },
  { user: "dmitry_action", game: "dead-cells", rating: 9, liked: true, favorite: true, status: "completed", hours: 120 },
  { user: "dmitry_action", game: "hades", rating: 9, liked: true, favorite: true, status: "completed", hours: 85 },
  { user: "dmitry_action", game: "resident-evil-4-remake", rating: 9, liked: true, favorite: false, status: "completed", hours: 35 },
  { user: "dmitry_action", game: "grand-theft-auto-v", rating: 9, liked: true, favorite: true, status: "completed", hours: 180 },

  # Elena (likes Indies, cosy & art): Hades, Hollow Knight, Stardew Valley, Celeste, Subnautica, Minecraft
  { user: "elena_indie", game: "hades", rating: 10, liked: true, favorite: true, status: "completed", hours: 90 },
  { user: "elena_indie", game: "hollow-knight", rating: 10, liked: true, favorite: true, status: "completed", hours: 75 },
  { user: "elena_indie", game: "stardew-valley", rating: 10, liked: true, favorite: true, status: "playing", hours: 160 },
  { user: "elena_indie", game: "celeste", rating: 10, liked: true, favorite: true, status: "completed", hours: 45 },
  { user: "elena_indie", game: "subnautica", rating: 10, liked: true, favorite: true, status: "completed", hours: 65 },
  { user: "elena_indie", game: "minecraft", rating: 9, liked: true, favorite: true, status: "playing", hours: 250 },
  { user: "elena_indie", game: "portal-2", rating: 9, liked: true, favorite: true, status: "completed", hours: 25 },

  # Artem (likes Tactics & Strategy): Baldur's Gate 3, Civilization VI, Persona 5, Forza, Mass Effect
  { user: "artem_tactics", game: "baldurs-gate-3", rating: 10, liked: true, favorite: true, status: "playing", hours: 140 },
  { user: "artem_tactics", game: "civilization-vi", rating: 9, liked: true, favorite: true, status: "playing", hours: 300 },
  { user: "artem_tactics", game: "persona-5-royal", rating: 10, liked: true, favorite: true, status: "completed", hours: 120 },
  { user: "artem_tactics", game: "mass-effect-legendary-edition", rating: 9, liked: true, favorite: true, status: "completed", hours: 90 },
  { user: "artem_tactics", game: "forza-horizon-5", rating: 8, liked: true, favorite: false, status: "playing", hours: 60 },
  { user: "artem_tactics", game: "the-witcher-3-wild-hunt", rating: 8, liked: true, favorite: false, status: "completed", hours: 70 }
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
