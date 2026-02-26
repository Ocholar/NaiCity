# Outreach Orchestrator Workflow (outreach_orchestrator.md)

**Trigger**: Cron – `*/15 8-18 * * *` (every 15 min during 08:00‑18:00 EAT)

**Nodes**:

1. **Start** – Schedule Trigger
2. **Set Lead Selection Query** – Set node with SQL (see spec) to fetch up to 10 leads ready for contact.
3. **PostgreSQL Query** – Postgres node executing the selection query, output array of leads.
4. **Loop** – Iterate over each lead.
   - **Rate Limit Check** – Function node reads Redis keys `whatsapp_sent_count` and `last_sent_timestamp` to enforce:
     - Max 30 messages/hour per sending number
     - Minimum 45 s between messages + random jitter 10‑30 s.
   - **Channel Decision** – If‑Switch node:
     - Condition 1: Valid phone & WhatsApp Business API available → Primary WhatsApp
     - Else if valid email → Primary Email
     - Else → Set lead status `needs_manual_review` and continue.
   - **Prepare Message** – HTTP Request to fetch message variant from `messages` table (by lead_id) or use default template.
   - **WhatsApp Send** – HTTP Request node to WhatsApp Cloud API `POST https://graph.facebook.com/v18.0/{{ $env.WHATSAPP_PHONE_NUMBER_ID }}/messages` with Bearer token.
     - On success, update lead `last_contact` timestamp and increment Redis counters.
     - On error codes (131026, 130429, 132000) handle via **If** nodes: fallback to email or schedule retry.
   - **Email Send** – (If chosen) SendGrid HTTP Request node with generated subject & HTML body (from prompt template).
   - **Update Lead Status** – Postgres node updating `leads` row: status = 'contacted', channel_used = 'whatsapp'/'email', contacted_at = NOW().
5. **End** – No further action.

**Notes**:

- Use **Set** nodes to map message JSON fields to API payloads.
- Store API responses in a temporary variable for debugging.
- All rate‑limit counters stored in Redis with TTL 1 hour.
- Ensure compliance with WhatsApp 24‑hour session window.

**Export**: Save as `outreach_orchestrator.md` under `n8n_workflows/`.
