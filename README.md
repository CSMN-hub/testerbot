# Bren Discord RAG Bot — Setup Pack

This pack launches a **stateless** Discord assistant that speaks like Bren, stays fresh from a private Google Drive folder (no public uploads), and logs every Q&A to Supabase.

## Files
- `supabase_bren_schema.sql` — run in Supabase SQL editor to create the necessary tables.
- `n8n_workflow_drive_ingest.json` — import to n8n. This workflow ingests documents from Google Drive.
- `n8n_workflow_discord_chat.json` — import to n8n. This workflow powers the Discord chat bot.
- `normalize_chunk_function.js` — (Informational) The javascript code used in the "Normalize, Chunk, Hash" node of the ingest workflow.
- `system_prompt_bren.txt` — (Informational) The system prompt used in the chat workflow.

## Supabase RPC Function

The chat workflow requires a SQL function in your Supabase project to perform vector similarity searches. Run the following SQL in your Supabase SQL editor:

```sql
-- Supabase RPC function to match documents based on vector similarity
create or replace function match_documents (
  query_embedding vector(1536),
  match_threshold float,
  match_count int
)
returns table (
  id bigint,
  source_id bigint,
  chunk_index int,
  topic_path text,
  speaker text,
  content text,
  tokens int,
  created_at timestamptz,
  similarity float
)
language sql stable
as $$
  select
    bren_chunks.id,
    bren_chunks.source_id,
    bren_chunks.chunk_index,
    bren_chunks.topic_path,
    bren_chunks.speaker,
    bren_chunks.content,
    bren_chunks.tokens,
    bren_chunks.created_at,
    1 - (bren_chunks.embedding <=> query_embedding) as similarity
  from bren_chunks
  where 1 - (bren_chunks.embedding <=> query_embedding) > match_threshold
  order by similarity desc
  limit match_count;
$$;
```

## Setup Steps

1.  **Supabase Setup**:
    *   In your Supabase project, go to the SQL Editor.
    *   Run the entire content of `supabase_bren_schema.sql`.
    *   Run the `match_documents` function SQL provided above.
    *   Get your Supabase project URL and API key.

2.  **n8n Setup**:
    *   Import both `n8n_workflow_drive_ingest.json` and `n8n_workflow_discord_chat.json` into your n8n instance.
    *   **Set Environment Variable**: In your n8n instance settings (or `docker-compose.yml` if self-hosting), set the `GDRIVE_FOLDER_ID` environment variable to the ID of the Google Drive folder you want to monitor.
    *   **Configure Credentials**: Create or configure the following credentials in n8n, then select them in the appropriate nodes in both workflows (nodes with credential placeholders are marked):
        *   **Google Drive**: Used in the "Drive Ingest" workflow.
        *   **OpenAI**: Used for creating embeddings in both workflows.
        *   **Supabase**: Used in both workflows to connect to your database.
        *   **Anthropic**: Used in the "Discord Chat" workflow for the language model.
        *   **Discord**: Used in the "Discord Chat" workflow.

3.  **Activate Workflows**:
    *   Enable both workflows in the n8n editor.
    *   To test the ingestion, add a file to your specified Google Drive folder.
    *   To test the chat, use the `/ask` command in Discord (e.g., `/ask question: What are your thoughts on risk management?`).
