# Bren Discord RAG Bot — Setup Pack

This pack launches a **stateless** Discord assistant that speaks like Bren, stays fresh from a private Google Drive folder (no public uploads), and logs every Q&A to Supabase.

## Files
- `supabase_bren_schema.sql` — run in Supabase SQL editor.
- `normalize_chunk_function.js` — paste into n8n Function node in the Drive workflow.
- `n8n_workflow_drive_ingest.json` — import to n8n and wire your credentials / folder id.
- `n8n_workflow_discord_chat.json` — import to n8n and wire Discord/OpenAI/Anthropic/Supabase.
- `system_prompt_bren.txt` — paste into Claude system prompt.

## Steps
1. Supabase → run SQL file, grab Postgres connection.
2. n8n → import both workflows; set credentials (Discord Bot, Supabase Postgres, OpenAI, Anthropic, Google Drive).
3. Set `GDRIVE_FOLDER_ID` env var in n8n for the Drive Trigger.
4. Paste `normalize_chunk_function.js` code into the Function node of the Drive workflow.
5. Start both workflows. Mention the bot or use `/ask` to test.
