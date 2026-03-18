-- ══════════════════════════════════════════════════════════════
-- HORNY PUG — SCHEMA SQL
-- Запусти это в Supabase → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Расширения
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ── USERS ──────────────────────────────────────────────────────
create table if not exists users (
  id          uuid primary key default uuid_generate_v4(),
  username    text unique not null,
  password    text not null,          -- bcrypt hash
  role        text not null default 'user', -- 'user' | 'mod' | 'admin'
  avatar_color text default '#f97316',
  bio         text default '',
  reputation  integer default 0,
  is_banned   boolean default false,
  ban_reason  text default '',
  created_at  timestamptz default now(),
  last_seen   timestamptz default now()
);

-- ── CATEGORIES ─────────────────────────────────────────────────
create table if not exists categories (
  id          serial primary key,
  name        text not null,
  slug        text unique not null,
  description text default '',
  icon        text default '💬',
  color       text default '#6c63ff',
  post_count  integer default 0,
  sort_order  integer default 0,
  created_at  timestamptz default now()
);

-- Дефолтные категории
insert into categories (name, slug, description, icon, color, sort_order) values
  ('Общее', 'general', 'Общие обсуждения', '💬', '#6c63ff', 1),
  ('Новости', 'news', 'Новости платформы и мира', '📰', '#38bdf8', 2),
  ('Помощь', 'help', 'Задавай вопросы', '🙋', '#10b981', 3),
  ('Медиа', 'media', 'Фото, видео, музыка', '🎬', '#f97316', 4),
  ('Оффтоп', 'offtopic', 'Всё что угодно', '🌀', '#a78bfa', 5)
on conflict do nothing;

-- ── POSTS ──────────────────────────────────────────────────────
create table if not exists posts (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid references users(id) on delete set null,
  category_id integer references categories(id) on delete set null,
  title       text not null,
  body        text not null,
  is_pinned   boolean default false,
  is_locked   boolean default false,
  is_deleted  boolean default false,
  views       integer default 0,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

-- ── COMMENTS ───────────────────────────────────────────────────
create table if not exists comments (
  id          uuid primary key default uuid_generate_v4(),
  post_id     uuid references posts(id) on delete cascade,
  user_id     uuid references users(id) on delete set null,
  body        text not null,
  is_deleted  boolean default false,
  created_at  timestamptz default now()
);

-- ── REACTIONS (лайки) ──────────────────────────────────────────
create table if not exists reactions (
  id          serial primary key,
  user_id     uuid references users(id) on delete cascade,
  post_id     uuid references posts(id) on delete cascade,
  type        text default 'like',
  created_at  timestamptz default now(),
  unique(user_id, post_id)
);

-- ── CHAT MESSAGES ──────────────────────────────────────────────
create table if not exists chat_messages (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid references users(id) on delete set null,
  body        text not null,
  created_at  timestamptz default now()
);

-- ── ANNOUNCEMENTS ──────────────────────────────────────────────
create table if not exists announcements (
  id          serial primary key,
  title       text not null,
  body        text not null,
  is_active   boolean default true,
  created_by  uuid references users(id),
  created_at  timestamptz default now()
);

-- ── BAN LOG ────────────────────────────────────────────────────
create table if not exists ban_log (
  id          serial primary key,
  user_id     uuid references users(id) on delete cascade,
  admin_id    uuid references users(id),
  action      text not null, -- 'ban' | 'unban'
  reason      text default '',
  created_at  timestamptz default now()
);

-- ── SITE SETTINGS ──────────────────────────────────────────────
create table if not exists site_settings (
  key         text primary key,
  value       text not null,
  updated_at  timestamptz default now()
);

insert into site_settings (key, value) values
  ('allow_registration', 'true'),
  ('site_description', 'Лучший форум в интернете'),
  ('maintenance_mode', 'false'),
  ('max_post_length', '10000'),
  ('max_comment_length', '2000')
on conflict do nothing;

-- ══════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS)
-- ══════════════════════════════════════════════════════════════

alter table users enable row level security;
alter table posts enable row level security;
alter table comments enable row level security;
alter table reactions enable row level security;
alter table chat_messages enable row level security;
alter table categories enable row level security;
alter table announcements enable row level security;
alter table ban_log enable row level security;
alter table site_settings enable row level security;

-- Политики: читать может всё, писать — только через API (service role)
create policy "Public read users" on users for select using (true);
create policy "Public read posts" on posts for select using (not is_deleted);
create policy "Public read comments" on comments for select using (not is_deleted);
create policy "Public read reactions" on reactions for select using (true);
create policy "Public read chat" on chat_messages for select using (true);
create policy "Public read categories" on categories for select using (true);
create policy "Public read announcements" on announcements for select using (is_active);
create policy "Public read settings" on site_settings for select using (true);

-- Через service_role (API) — полный доступ (обходит RLS)
-- Наш Next.js backend использует service role key, поэтому всё работает

-- ══════════════════════════════════════════════════════════════
-- REALTIME (для чата)
-- ══════════════════════════════════════════════════════════════
-- Supabase → Database → Replication → включи таблицу chat_messages

-- ══════════════════════════════════════════════════════════════
-- ФУНКЦИИ
-- ══════════════════════════════════════════════════════════════

-- Инкремент views
create or replace function increment_views(post_id uuid)
returns void language sql as $$
  update posts set views = views + 1 where id = post_id;
$$;

-- Обновление репутации
create or replace function update_reputation(uid uuid, delta integer)
returns void language sql as $$
  update users set reputation = reputation + delta where id = uid;
$$;

-- ══════════════════════════════════════════════════════════════
-- ИНДЕКСЫ
-- ══════════════════════════════════════════════════════════════
create index if not exists idx_posts_user on posts(user_id);
create index if not exists idx_posts_category on posts(category_id);
create index if not exists idx_posts_created on posts(created_at desc);
create index if not exists idx_comments_post on comments(post_id);
create index if not exists idx_reactions_post on reactions(post_id);
create index if not exists idx_chat_created on chat_messages(created_at desc);
create index if not exists idx_users_username on users(username);
