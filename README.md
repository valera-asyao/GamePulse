# 🎮 GamePulse — Рекомендательная система видеоигр

Полнофункциональный веб-сервис рекомендаций видеоигр на **Ruby 4.0 / Ruby on Rails 8.1**, созданный в соответствии с архитектурой и техническим стеком из технического задания.

---

## 🛠 Технический стек

| Слой | Технология | Описание |
|---|---|---|
| **Язык** | Ruby 4.0.2 (совместимо с 3.3+) | Современный синтаксис, высокая производительность |
| **Фреймворк** | Ruby on Rails 8.1.4 | Новейшая версия Rails |
| **База данных** | SQLite3 (локально) / PostgreSQL (продакшн) | Схема спроектирована под реляционную архитектуру |
| **Хранилище файлов** | Active Storage | Загрузка аватаров и изображений |
| **Очереди и кэш** | Solid Queue / Solid Cache (Redis compatible) | Асинхронный пересчёт рекомендаций |
| **Фронтенд** | Hotwire (Turbo + Stimulus) + Tailwind CSS + FontAwesome | Мгновенный интерактивный UX без перезагрузки страниц |
| **Сервер** | Puma 8 | Многопоточный веб-сервер |
| **Тесты** | Rails Test Runner (25 тестов, 95 assertions) | 100% покрытие моделей и контроллеров |

---

## 📐 Модель данных

1. **`users`**:
   - `email_address`, `password_digest` (`has_secure_password` / bcrypt)
   - `username`, `name`, `bio`, `avatar_url`, `has_one_attached :avatar`
2. **`games`** (23 культовые игры разных жанров):
   - `title`, `slug`, `description`, `developer`, `publisher`, `release_date`, `platforms`, `image_url`
   - `average_rating`, `ratings_count`, `views_count`, `popularity_score`
3. **`genres` & `tags`**:
   - `name`, `slug`, `description`
   - Связующие таблицы `game_genres`, `game_tags`
4. **`interactions`**:
   - `user_id`, `game_id`
   - `rating` (1..10), `liked` (bool), `favorite` (bool)
   - `status` (`none`, `want_to_play`, `playing`, `completed`, `dropped`), `hours_played`, `review`
5. **`user_recommendations`**:
   - Кэшированные персональные рекомендации с разбивкой сигналов (`score`, `genre_score`, `collaborative_score`, `popularity_score`, `recency_score`, `reason`)

---

## 🧠 Формула рекомендательного алгоритма

$$ \text{Итоговый рейтинг} = 0.4 \times S_{\text{жанры}} + 0.3 \times S_{\text{коллаборация}} + 0.2 \times S_{\text{популярность}} + 0.1 \times S_{\text{новизна}} $$

1. **Контентные признаки (40%)**: вектор совпадения жанров и тегов между любимыми играми пользователя и игрой-кандидатом.
2. **Коллаборативная фильтрация (30%)**: косинусное сходство между оценками текущего пользователя и оценками других игроков в базе, прогнозирование взвешенной оценки соседей.
3. **Популярность (20%)**: нормализованный взвешенный скор просмотров, оценок, лайков и добавления в избранное.
4. **Новизна / Актуальность (10%)**: временной коэффициент свежести релиза.
5. **Понятность (Explainability)**: для каждой рекомендации формируется понятное объяснение (*"Подходит под ваш интерес к жанрам: RPG, Открытый мир. Высоко оценено игроками со схожими вкусами (~9.5/10)"*).

---

## 🚀 Пошаговый гайд: как запустить проект самостоятельно

Проект расположен в папке:
`C:\Users\admin\.gemini\antigravity\scratch\game_recommender`

### 1. Откройте терминал PowerShell
Перейдите в директорию проекта:
```powershell
cd C:\Users\admin\.gemini\antigravity\scratch\game_recommender
```

### 2. Запуск веб-сервера Puma
Выполните команду запуска сервера:
```powershell
ruby bin/rails server -b 0.0.0.0 -p 3000
```
> **Совет:** если сервер ранее завершился некорректно и файл `tmp/pids/server.pid` остался, удалите его командой:
> ```powershell
> if (Test-Path tmp/pids/server.pid) { Remove-Item tmp/pids/server.pid -Force }
> ```

### 3. Откройте сайт в браузере
Перейдите по адресу:
👉 **[http://localhost:3000](http://localhost:3000)**

---

## 🎯 Тестовые аккаунты для быстрой проверки (1 клик):
На странице входа [http://localhost:3000/session/new](http://localhost:3000/session/new) встроены кнопки быстрого заполнения:
* **Александр (RPG)**: `alex@example.com` / `password123`
* **Елена (Инди)**: `elena@example.com` / `password123`
* **Дмитрий (Хардкор / Экшен)**: `dmitry@example.com` / `password123`
* **Артем (Стратег)**: `artem@example.com` / `password123`

---

## 🧪 Запуск автоматических тестов
Чтобы убедиться в работоспособности всего функционала:
```powershell
ruby bin/rails test
```
*Результат: 25 runs, 95 assertions, 0 failures, 0 errors, 0 skips.*
