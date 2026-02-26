# Deployment Checklist

## Infrastructure setup

- [ ] Deploy n8n instance (Railway, Render, DigitalOcean, or your own server via Docker Compose)
- [ ] Provision PostgreSQL database and apply `database/schema.sql`
- [ ] Provision Redis instance for queue management and caching

## API & Integrations

- [ ] WhatsApp Business API approved via Meta Developer Portal
- [ ] OpenAI API key generated and billing active (GPT-4o text embeddings and chat models set up)
- [ ] Anthropic API key generated for Claude 3 Haiku intent classification
- [ ] Pinecone vector index created (dimensions: 1536, name: `naicity-conversations`)
- [ ] Google Maps Places API enabled and key generated
- [ ] Clearbit / ScrapingBee API keys ready (if using fallback enrichment)
- [ ] SendGrid API key generated for email fallback

## Application Configuration

- [ ] Update `.env` file with all production secrets (see `.env.example`)
- [ ] Test the Naicity Affiliate Link (`https://naicity.com/aff/198/`) and ensure tracking is active
- [ ] Configure n8n webhook endpoints in Meta for incoming WhatsApp messages (`POST /webhook/whatsapp`)
- [ ] Configure Naicity conversion webhook inside Naicity dashboard (`POST /webhook/naicity-conversion`)

## Testing & Launch

- [ ] Set up error alerting (e.g. Telegram Bot via HTTP Request nodes)
- [ ] Import and test the 6 workflows locally using `npm run test` or mock payloads
- [ ] Manually process the first 10 leads to validate personalization and safety limits
- [ ] Activate A/B test framework by verifying the `messages` variant selection is firing correctly
- [ ] Verify the daily analytics dashboard and conversion attribution report
