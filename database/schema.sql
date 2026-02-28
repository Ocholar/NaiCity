-- schema.sql
-- Lead structure
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TABLE leads (
    lead_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    location_area VARCHAR(100),
    location_landmark VARCHAR(255),
    location_lat FLOAT,
    location_lng FLOAT,
    contact_phone VARCHAR(50),
    contact_email VARCHAR(255),
    contact_whatsapp_optimal_time VARCHAR(50),
    social_rating FLOAT,
    social_review_count INT,
    social_recent_reviews JSONB,
    social_photos_detected INT,
    insights_missing_website BOOLEAN,
    insights_missing_social BOOLEAN,
    insights_competitor_ads_running BOOLEAN,
    insights_high_value_indicators JSONB,
    status VARCHAR(50) DEFAULT 'enriched',
    last_contact TIMESTAMP,
    channel_used VARCHAR(50),
    conversion_time_hours FLOAT,
    enrichment_timestamp TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);
-- AI generated messages
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id UUID REFERENCES leads(lead_id),
    message_variant_a TEXT,
    message_variant_b TEXT,
    message_variant_c TEXT,
    personalization_signals_used JSONB,
    recommended_send_time VARCHAR(10),
    follow_up_angle TEXT,
    confidence_score FLOAT,
    created_at TIMESTAMP DEFAULT NOW()
);
-- Conversations table
CREATE TYPE message_direction AS ENUM ('outbound', 'inbound');
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id UUID REFERENCES leads(lead_id),
    message_id VARCHAR(255) UNIQUE,
    -- WhatsApp message ID
    direction message_direction,
    content TEXT,
    intent_classification VARCHAR(50),
    metadata JSONB,
    -- {tokens_used, model, latency_ms}
    created_at TIMESTAMP DEFAULT NOW(),
    thread_id VARCHAR(255) -- For grouping
);
-- Memory retrieval function (vector search removed)
CREATE OR REPLACE FUNCTION get_conversation_context(
        p_lead_id UUID,
        p_limit INT DEFAULT 5
    ) RETURNS TABLE (content TEXT, direction VARCHAR) AS $$ BEGIN RETURN QUERY
SELECT c.content,
    c.direction::VARCHAR
FROM conversations c
WHERE c.lead_id = p_lead_id
ORDER BY c.created_at DESC
LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
-- Conversions and Analytics Table
CREATE TABLE conversions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id UUID REFERENCES leads(lead_id),
    affiliate_id INT,
    plan_type VARCHAR(100),
    commission FLOAT,
    signup_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);