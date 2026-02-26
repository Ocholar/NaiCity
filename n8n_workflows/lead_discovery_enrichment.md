# Lead Discovery & Enrichment Workflow (lead_discovery_enrichment.md)

**Trigger**: Schedule (Cron) – `0 8 * * *` (daily at 08:00 EAT)

**Nodes**:

1. **Start** – Schedule Trigger
2. **Parallel Split** – Execute three parallel branches for data sources.
   - **Google Maps Places** – HTTP Request node:
     - URL: `https://maps.googleapis.com/maps/api/place/textsearch/json`
     - Query Params: `query=restaurants+in+{{ $json.area }}` & `key={{ $env.GOOGLE_MAPS_API_KEY }}`
     - Iterate over a predefined list of Nairobi neighborhoods (array node).
   - **Facebook Graph API** – HTTP Request node:
     - URL: `https://graph.facebook.com/v18.0/search`
     - Params: `type=page&q={{ $json.category }}&center={{ $json.lat }},{{ $json.lng }}&distance=5000&access_token={{ $env.FACEBOOK_TOKEN }}`
   - **Instagram Scraper** – HTTP Request (via ScrapingBee) node:
     - URL: `https://app.scrapingbee.com/api/v1/` with target `https://www.instagram.com/explore/tags/{{ $json.hashtag }}/`
3. **Merge Results** – Function node to combine arrays from the three branches.
4. **Deduplication** – Function node:
   - Normalize phone numbers to local format (`07XXXXXXXX`).
   - Compute Levenshtein distance for business names (<3) and drop duplicates.
   - Geohash comparison (precision 6) for address matching.
5. **Enrichment** – HTTP Request node to Clearbit API (optional) and fallback to ScrapingBee for website data.
6. **Scoring** – Function node calculates `score = (review_count * rating) + (social_followers / 1000)` and assigns priority tag.
7. **PostgreSQL Insert** – Postgres node inserting into `leads` table with status `'enriched'`.
8. **End** – No further action.

**Notes**:

- Use **Set** nodes to map API responses to a unified lead schema (see JSON example in spec).
- Add error handling with **IF** nodes: on API failure, continue with remaining sources.
- Store raw API payloads in a temporary variable for debugging.

**Export**: Save this workflow as `lead_discovery_enrichment.md` under `n8n_workflows/`.
