
-- Enable pgvector
create extension if not exists vector;

-- Source files table (one row per uploaded transcript file)
create table if not exists bren_sources (
  id bigserial primary key,
  filename text not null,
  source_url text,
  hash_sha256 text unique,
  kind text,                   -- md|txt|vtt|srt|other
  stream_title text,
  stream_date date,
  created_at timestamptz default now()
);

-- Chunks table (vectorized passages for RAG)
create table if not exists bren_chunks (
  id bigserial primary key,
  source_id bigint references bren_sources(id) on delete cascade,
  chunk_index int,
  topic_path text,
  speaker text,
  content text,
  tokens int,
  created_at timestamptz default now(),
  embedding vector(1536)
);

-- Indices for fast similarity search and joins
create index if not exists bren_chunks_embedding_idx on bren_chunks using ivfflat (embedding vector_cosine_ops) with (lists = 100);
create index if not exists bren_chunks_source_idx on bren_chunks(source_id);

-- Logging table (every Q&A, stateless bot)
create table if not exists chat_logs (
  id bigserial primary key,
  discord_message_id text,
  channel_id text,
  user_id text,
  username text,
  question text,
  answer text,
  model text,
  prompt_tokens int,
  completion_tokens int,
  latency_ms int,
  created_at timestamptz default now()
);
