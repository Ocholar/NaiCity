# NaiCity Affiliate Automation Engine

An autonomous, AI-powered system designed to scrape unlisted Nairobi businesses, enrich their data, generate personalized outreach messages via OpenAI, execute multi-channel outreach through n8n, handle incoming context-aware responses with Anthropic/OpenAI, and track affiliate conversions for Naicity.

## Core Architecture

- **Data Layer:** Google Maps Places, Facebook Graph SDK, Instagram location tagging, Clearbit, and ScrapingBee.
- **Intelligence Layer:** OpenAI GPT-4o, Anthropic Claude 3 Haiku, Pinecone Vector DB.
- **Orchestration Layer:** n8n Workflow Automation, PostgreSQL, Redis.

## System Setup Steps Undertaken

### 1. Workflow Generation

We defined 6 intelligent n8n workflows logically broken down:

- `lead_discovery_enrichment.md`: Scraping and data normalization.
- `ai_message_generation.md`: LLM prompt construction and processing.
- `outreach_orchestrator.md`: Queueing and rate-limiting WhatsApp and Email dispatches.
- `response_handler.md`: Intent classification, Pinecone RAG fetching, and automated replies.
- `follow_up_intelligence.md`: Cadenced re-contact generation for unengaged leads.
- `conversion_tracking_analytics.md`: Affiliate hit detection and daily Telegram roll-up reporting.

### 2. Prompt Templates

Structured JSONs ensuring strict AI guidelines for OpenAI to abide by while keeping communications WhatsApp-friendly.

- Located in `n8n_workflows/prompt_templates/`

### 3. Database Schema

Provisioned `database/schema.sql` handling:

- `leads`: Storing enriched contact information and social performance markers.
- `messages`: Generated message variables and scores.
- `conversations`: Recording WhatsApp chat history and intent classifications with vectors.
- `conversions`: Storing affiliate tracking.

### 4. Containerization

Created a custom `docker-compose.yml` that seamlessly boots PostgreSQL, Redis caching layers, and the primary n8n instance.

## Deployment Guidelines

If configuring from scratch, please ensure to configure the respective API Keys detailed in `.env.example` inside your deployed environment variable management console (e.g. Railway). Refer to `DEPLOYMENT.md` for specific third-party integration steps (WhatsApp Cloud API, Pinecone, Google Maps, OpenAI, SendGrid) and pre-flight checks.
