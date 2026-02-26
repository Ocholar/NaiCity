# Follow-Up Intelligence Workflow (follow_up_intelligence.md)

**Trigger**: Cron – `0 10 * * *` (Daily at 10:00 EAT)

**Nodes**:

1. **Start** – Schedule Trigger
2. **Postgres Query (Candidates)** – Postgres node executing SQL to find leads:
   - Status != 'converted', 'dnc', 'nurture'
   - `last_contact` > 48 hours ago
   - No inbound response
   - Follow-up attempt count < 3
3. **Loop** – Iterate over matching leads.
   - **Determine Attempt** – Set node defining the current attempt (Attempt 1: 48h, Attempt 2: 5d, Attempt 3: 10d).
   - **Variant Selection** – Function node:
     - Select follow-up angle (e.g., soft reminder, social proof, final check).
   - **Context Retrieval** – Postgres node fetching previous outbound message from `conversations`.
   - **Dynamic Content Generation** – OpenAI GPT-4o node:
     - Generate message referencing previous message.
     - Lower pressure tone.
   - **Schedule Outreach** – Postgres node inserts the new message into the `messages` table with high confidence, and updates lead to clear `last_contact` so orchestrator picks it up.
   - **Increment Attempt** – Postgres node increments a follow-up counter on the lead or related table.
4. **End** – No further action.

**Notes**:

- Consider adding logic in the Function node for a simple ML model or heuristic to predict optimal send time based on Redis cached response times.
- Ensure the Orchestrator (workflow 3) handles the actual sending of these generated follow-up messages.

**Export**: Save as `follow_up_intelligence.md` under `n8n_workflows/`.
