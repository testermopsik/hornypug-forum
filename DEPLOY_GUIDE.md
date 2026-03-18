# 🐾 HORNY PUG — ИНСТРУКЦИЯ ПО ДЕПЛОЮ
## От нуля до живого сайта за ~30 минут

---

## 📋 ЧТО ТЕБЕ НУЖНО (всё бесплатно)
- Аккаунт на GitHub: https://github.com
- Аккаунт на Supabase: https://supabase.com  
- Аккаунт на Vercel: https://vercel.com
- (Опционально) Домен: https://reg.ru или https://namecheap.com

---

## ШАГ 1 — Создать базу данных (Supabase)

1. Зайди на **supabase.com** → New Project
2. Придумай название (например `hornypug`) и пароль базы
3. Дождись создания (~1 минута)
4. Зайди в **SQL Editor** (левое меню) → New Query
5. Скопируй ВЕСЬ текст из файла `supabase-schema.sql` → вставь → нажми **RUN**
6. Убедись, что внизу написало `Success`

### Получить ключи API:
- Левое меню → **Settings** → **API**
- Скопируй:
  - `Project URL` → это `NEXT_PUBLIC_SUPABASE_URL`
  - `anon public` → это `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  - `service_role` → это `SUPABASE_SERVICE_ROLE_KEY` ⚠️ секрет!

### Включить Realtime (для чата):
- Левое меню → **Database** → **Replication**
- Найди таблицу `chat_messages` → включи

---

## ШАГ 2 — Загрузить код на GitHub

1. Зайди на **github.com** → New Repository
2. Назови `hornypug-forum` → Create
3. Загрузи ВСЕ файлы из папки `hornypug/` в репозиторий
   (можно через кнопку "uploading an existing file" или через Git)

### Через терминал (если знаешь):
```bash
cd hornypug
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/ТВО_НИК/hornypug-forum.git
git push -u origin main
```

---

## ШАГ 3 — Деплой на Vercel

1. Зайди на **vercel.com** → Add New Project
2. Нажми **Import** рядом с твоим репозиторием `hornypug-forum`
3. Framework: выбери **Next.js** (автоматически определится)
4. Нажми **Environment Variables** и добавь:

```
NEXT_PUBLIC_SUPABASE_URL = https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY = eyJhbGci...
SUPABASE_SERVICE_ROLE_KEY = eyJhbGci...
JWT_SECRET = придумай_любую_длинную_строку_32_символа
NEXT_PUBLIC_SITE_URL = https://твой-проект.vercel.app
```

5. Нажми **Deploy** → подожди ~2 минуты
6. Готово! Сайт живёт на `https://твой-проект.vercel.app`

---

## ШАГ 4 — Создать первого Администратора

После деплоя:
1. Зайди на свой сайт → **Регистрация**
2. Зарегистрируйся с ником и паролем
3. Зайди в **Supabase** → **Table Editor** → таблица `users`
4. Найди свою запись → измени поле `role` с `user` на `admin`
5. Перезайди на сайт — ты теперь администратор!

---

## ШАГ 5 (опционально) — Подключить свой домен

### Купить домен:
- **reg.ru** — дёшево для .ru (от 99₽/год)
- **namecheap.com** — хорошо для .com/.net
- **porkbun.com** — часто дешевле

### Подключить к Vercel:
1. Vercel → твой проект → **Settings** → **Domains**
2. Нажми **Add** → введи свой домен
3. Vercel покажет DNS записи которые нужно добавить
4. Зайди к своему регистратору → DNS настройки → добавь:
   - `A` запись: `@` → IP от Vercel
   - `CNAME` запись: `www` → `cname.vercel-dns.com`
5. Подожди 5-30 минут → HTTPS включится автоматически

---

## 🎮 УПРАВЛЕНИЕ САЙТОМ (без кода!)

### Войди как администратор и используй панель `/admin`:

| Функция | Где |
|---------|-----|
| Забанить/разбанить пользователя | Панель → Пользователи |
| Удалить пост | Панель → Посты |
| Закрепить пост | Панель → Посты |
| Заблокировать тему | Панель → Посты |
| Добавить категорию | Панель → Категории |
| Опубликовать объявление | Панель → Объявления |
| Закрыть регистрацию | Панель → Настройки |
| Дать модератора | Панель → Пользователи → Роль |
| Статистика сайта | Панель → Дашборд |

---

## 🔒 БЕЗОПАСНОСТЬ

Сайт защищён:
- ✅ **Bcrypt** (сложность 12) — пароли
- ✅ **JWT + HttpOnly cookie** — сессии (недоступны JS)
- ✅ **Rate limiting** — защита от брутфорса (10 попыток / 15 мин)
- ✅ **Row Level Security** — Supabase не даёт обойти права
- ✅ **Серверный рендеринг** — все проверки на сервере
- ✅ **HTTPS** — автоматически через Vercel

---

## 🛠️ ЕСЛИ ЧТО-ТО НЕ РАБОТАЕТ

**Ошибка "supabase not configured":**
→ Проверь переменные окружения в Vercel

**Ошибка при регистрации:**
→ Убедись что запустил supabase-schema.sql

**Чат не обновляется в реальном времени:**
→ Включи Replication для таблицы chat_messages в Supabase

**Нет прав администратора:**
→ Измени поле role в таблице users в Supabase

**Сайт не доступен по домену:**
→ Подожди 30-60 минут для распространения DNS

---

## 📁 СТРУКТУРА ПРОЕКТА

```
hornypug/
├── src/
│   ├── pages/
│   │   ├── index.tsx          ← Главная страница
│   │   ├── forum.tsx          ← Форум
│   │   ├── chat.tsx           ← Живой чат
│   │   ├── members.tsx        ← Участники
│   │   ├── admin.tsx          ← Панель администратора
│   │   ├── login.tsx          ← Вход
│   │   ├── register.tsx       ← Регистрация
│   │   ├── settings.tsx       ← Настройки профиля
│   │   ├── post/[id].tsx      ← Страница поста
│   │   ├── user/[username].tsx← Профиль пользователя
│   │   └── api/               ← Backend API routes
│   │       ├── auth/          ← Авторизация
│   │       ├── posts/         ← Посты
│   │       ├── comments/      ← Комментарии
│   │       ├── reactions/     ← Лайки
│   │       ├── chat/          ← Чат
│   │       ├── members.ts     ← Участники
│   │       ├── settings/      ← Настройки
│   │       └── admin/         ← Администрирование
│   ├── components/
│   │   └── Navbar.tsx         ← Навигация
│   ├── lib/
│   │   ├── supabase.ts        ← База данных
│   │   └── auth.ts            ← JWT авторизация
│   └── styles/
│       └── globals.css        ← Глобальные стили
├── supabase-schema.sql        ← SQL для базы данных
├── .env.example               ← Шаблон переменных
├── next.config.js
├── package.json
└── tsconfig.json
```

---

## 💰 СТОИМОСТЬ

| Сервис | Стоимость |
|--------|-----------|
| Vercel | **Бесплатно** (до 100GB трафика) |
| Supabase | **Бесплатно** (до 500MB базы, 2GB трафика) |
| Домен .ru | ~99-299₽/год |
| Домен .com | ~$10-15/год |

**Итого: от 0₽ до ~300₽/год**

---

Удачи с запуском! 🐾
