# AI Message Generation Workflow (ai_message_generation.md)

**Trigger**: Webhook – `POST /webhook/lead-discovery` (called per lead after enrichment)

**Nodes**:

1. **Start** – Webhook node receives lead payload.
2. **Set Context** – Function node builds context object:
   - Pull latest 3 Google reviews via HTTP Request (Google Places Details API).
   - Retrieve business hours, competitor hours, price range, neighborhood events (custom API or static data).
3. **Prompt Construction** – Function node assembles the system prompt (see spec) and inserts lead‑specific variables.
4. **OpenAI GPT‑4o** – OpenAI node:
   - Model: `gpt-4o`
   - Temperature: `0.7`
   - Max tokens: `200`
   - Returns JSON with message variants, signals, send time, follow‑up angle, confidence.
5. **Post‑Processing** – Function node runs profanity filter, checks forbidden words, ensures affiliate link insertion.
6. **A/B Test Assignment** – Set node chooses variant A/B/C based on round‑robin counter stored in Redis.
7. **PostgreSQL Insert** – Postgres node writes record to `messages` table linking `lead_id`.
8. **End** – No further action.

**Notes**:

- Use **If** nodes to handle API errors; on failure fallback to a static template.
- Store raw LLM response in a JSON column for audit.
- Increment Redis counter `message_variant_counter` for balanced distribution.

**Export**: Save as `ai_message_generation.md` under `n8n_workflows/`.
