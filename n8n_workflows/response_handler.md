# Response Handler Workflow (response_handler.md)

**Trigger**: Webhook – `POST /webhook/whatsapp` (incoming WhatsApp messages)

**Nodes**:

1. **Start** – Webhook node receives inbound message payload.
2. **Parse Message** – Function node extracts `message_id`, `from` (phone), `timestamp`, `text.body`.
3. **Store Raw** – Postgres node inserts raw inbound data into `conversations` table (direction='inbound').
4. **Intent Classification** – Anthropic Claude 3 Haiku node:
   - Prompt includes list of intents (INTERESTED, QUESTION, OBJECTION, NOT_INTERESTED, WRONG_NUMBER, SPAM) and asks for JSON with `intent`, `urgency`, `style`, `questions`.
   - Output stored in variable `classification`.
5. **Embedding** – OpenAI Embedding node (text-embedding-3-small) on incoming text, result stored in `embedding`.
6. **Vector Store Query** – Pinecone node:
   - Query with `embedding`, top_k=5, filter `lead_id` matching the phone number (lookup lead via Postgres node first).
   - Returns similar past conversation snippets.
7. **Context Assembly** – Function node builds a context object containing:
   - Lead enrichment data (from `leads` table via Postgres lookup).
   - Retrieved similar conversation snippets.
   - Classification results.
8. **Response Generation** – OpenAI GPT‑4o node:
   - System prompt describes role (WhatsApp assistant for Nairobi businesses).
   - Includes context and incoming message.
   - Constraints: max 60 words, no salesy language on objections, include affiliate link only when appropriate.
   - Returns plain text response.
9. **Post‑Processing** – Function node applies profanity filter and checks for disallowed phrases.
10. **Store Outbound** – Postgres node inserts generated response into `conversations` table (direction='outbound') with intent and metadata.
11. **Decision – Escalate?** – If `classification.intent` is NOT_INTERESTED or confidence < 0.6, route to **Telegram Alert** node (send message to human operator) and stop.
12. **Send WhatsApp** – HTTP Request node to WhatsApp Cloud API `POST https://graph.facebook.com/v18.0/{{ $env.WHATSAPP_PHONE_NUMBER_ID }}/messages` with text payload.
13. **Update Lead Status** – Postgres node updates `leads` row: `last_contact = NOW()`, `status = 'responded'`.
14. **End** – No further action.

**Notes**:

- Use **If** nodes to handle API errors; on failure, log and optionally retry.
- Store LLM response JSON in a separate column for audit.
- Increment Redis counter `whatsapp_inbound_rate` for monitoring.

**Export**: Save as `response_handler.md` under `n8n_workflows/`.
