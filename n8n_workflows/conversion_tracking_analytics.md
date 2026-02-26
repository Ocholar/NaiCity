# Conversion Tracking & Analytics Workflow (conversion_tracking_analytics.md)

**Trigger**:

1. Webhook – `POST /webhook/naicity-conversion` (Real-time conversion events)
2. Cron – `59 23 * * *` (Daily summary at 23:59 EAT)

**Nodes (Conversion Event Branch)**:

1. **Conversion Webhook** – Receives payload from Naicity: `{ affiliate_id, business_name, signup_date, plan_type, commission }`.
2. **Match Lead** – Postgres node to find `lead_id` using fuzzy matching on `business_name` (or precise matching if affiliate links contain custom parameters like tracking IDs).
3. **Update Lead** – Postgres node updating `leads` table:
   - `status = 'converted'`
   - `conversion_time_hours = EXTRACT(EPOCH FROM (NOW() - created_at))/3600`
4. **Record Commission** – Postgres node inserting into a `commissions` or `conversions` table.
5. **Alert Telegram** – HTTP Request node to Telegram API (Bot) to send a celebratory message with commission amount.

**Nodes (Daily Aggregation Branch)**:

1. **Cron Trigger** – End of day.
2. **Execute Aggregation Array** – Postgres node running:

   ```sql
   SELECT 
     COUNT(*) as leads_enriched,
     SUM(CASE WHEN status IN ('contacted', 'responded', 'converted') THEN 1 ELSE 0 END) as reached_out,
     SUM(CASE WHEN status IN ('responded', 'converted') THEN 1 ELSE 0 END) as responses,
     SUM(CASE WHEN status = 'converted' THEN 1 ELSE 0 END) as conversions
   FROM leads WHERE DATE(created_at) = CURRENT_DATE;
   ```

3. **Compute Metrics** – Function node computing conversion rate, CPA (using static assumed OpenAI cost or queried token costs).
4. **Alert Telegram (Daily Report)** – HTTP Request node sending aggregated daily stats to the Telegram channel.

**Export**: Save as `conversion_tracking_analytics.md` under `n8n_workflows/`.
